# Lecture 9 : Prototyping at the scanner with MATLAB  part 1

Title : Prototyping at the scanner with MATLAB part 1

Schedule : June 25, 2020 | 15:00-16:00

Speakers : Aurélien Trotier & Stanislas Rapacchi



## Summary

- [Foreword](#foreword)
 - [Setup for demo](#Setup-for-demo)
 - [Read the trajectory](#Read-the-trajectory)
    - [Take a look at the data](#Take-a-look-at-the-data)
    - [Correct the reader](#Correct-the-reader)
    - [Conclusion for trajectory](#Conclusion-for-trajectory)
 - [Reconstruction of non-cartesian data using BART](#Reconstruction-of-non-cartesian-data-using-BART)
    - [Data format in BART](#Data-format-in-BART)
    - [Simple gridding Adjoint](#Simple-gridding-Adjoint)
    - [Iterative gridding Inverse](#Iterative-gridding-Inverse)
- [Send the data](#Send-the-data)
- [Conclusion](#Conclusion)



## Foreword

Cartesian acquisition is a well known and documented type of MRI  acquisition and Gadgetron is well equipped to reconstruct this kind of  trajectory without going in a matlab/python gadget. non-Cartesian  acquisition has shown great promises in research however the flexibility in the trajectory choice is not well manage (for now) by Gadgetron  during the reconstruction.

In this demo we will show you how to reconstruct a non-Cartesian  dataset (spiral) using the BART toolbox. Our Matlab gadget needs to :

- Read the trajectory
- Gridding : resample the non-Cartesian data on the k-space grid.
- Estimate the coil sensitivity
- Generate images
- Send images



## Setup for demo

In this example we will use a 2D spiral dataset : **spiral_2D_ssfp.h5** available at [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3888658.svg)](https://doi.org/10.5281/zenodo.3888658). After the previous demo, you might be used to the following part :

First you need to create the Gadgetron config file **demo_2_nonCart.xml**.

Because we use a Matlab gadget to manage the non-Cartesian  reconstruction, the config file is equivalent to a standard Cartesian  config file finishing by the **BucketToBufferGadget** before the call to Matlab.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <version>2</version>

    <readers>
        <reader>
            <dll>gadgetron_core_readers</dll>
            <classname>AcquisitionReader</classname>
        </reader>
        <reader>
            <dll>gadgetron_core_readers</dll>
            <classname>WaveformReader</classname>
        </reader>
    </readers>

    <writers>
        <writer>
            <dll>gadgetron_core_writers</dll>
            <classname>ImageWriter</classname>
        </writer>
    </writers>

    <stream>
        <gadget>
            <dll>gadgetron_mricore</dll>
            <classname>NoiseAdjustGadget</classname>
        </gadget>

        <gadget>
            <dll>gadgetron_mricore</dll>
            <classname>RemoveROOversamplingGadget</classname>
        </gadget>

        <gadget>
          <name>PCA</name>
          <dll>gadgetron_mricore</dll>
          <classname>PCACoilGadget</classname>
        </gadget>

        <gadget>
          <name>CoilReduction</name>
          <dll>gadgetron_mricore</dll>
          <classname>CoilReductionGadget</classname>
          <property name="coils_out" value="4"/>
        </gadget>

          <!-- Data accumulation and trigger gadget -->
    <gadget>
        <name>AccTrig</name>
        <dll>gadgetron_mricore</dll>
        <classname>AcquisitionAccumulateTriggerGadget</classname>
        <property><name>trigger_dimension</name><value>repetition</value></property>
        <property><name>sorting_dimension</name><value></value></property>
    </gadget>

    <gadget>
        <name>BucketToBuffer</name>
        <dll>gadgetron_mricore</dll>
        <classname>BucketToBufferGadget</classname>
        <property><name>N_dimension</name><value>phase</value></property>
        <property><name>S_dimension</name><value>set</value></property>
        <property><name>split_slices</name><value>false</value></property>
        <property><name>ignore_segment</name><value>true</value></property>
        <property><name>verbose</name><value>true</value></property>
    </gadget>
    
        <external>
            <!-- Connect to a running process on port 18000. -->
            <connect port="18000"/>

            <!-- The configuration is sent to the external process. It's left pretty empty here. -->
            <configuration/>
        </external>
    </stream>
</configuration>
```

Then we will create a matlab function which will be called by Gadgetron : **GT_reco_nonCart.m**

```matlab
function GT_reco_nonCart(connection)
disp("GT_reco_nonCart was called.")
next_acquisition = @connection.next;

acquisition = next_acquisition(); % Call input function to produce the next 
end
```

This function is pretty empty but we want to prototype the reconstruction from there. For prototyping we will work in matlab debug mode :

- Put a breakpoint at the beginning of the matlab function.
- in matlab console -> `gadgetron.external.listen(18000,@GT_reco_nonCart)``
- start gadgetron server in a console : `gadgetron`
- call gadgetron from the client (change the path of input/ouput/config file) :

```shell
gadgetron_ismrmrd_client -f /home/atrotier/GITHUB/EDUC_GT_MATLAB/data/spiral_2D_ssfp.h5 -o /home/atrotier/GITHUB/EDUC_GT_MATLAB/data/out/out_spiral_2D.h5 -C /home/atrotier/GITHUB/EDUC_GT_MATLAB/config/demo_2_nonCart.xml
```

Matlab should stop the script at your breakpoint.



## Read the trajectory

### Take a look at the data

We first want to know how is stored the non-Cartesian data and what  field is available. Put a breakpoint on end and take a look at **acquisition**. Some fields are empty, like **acquisition.bits.reference** which means no readout has been tag as a reference readout in the sequence.

In the buffer we have access to these fields :

```matlab
acquisition.bits.buffer.data
acquisition.bits.buffer.trajectory
acquisition.bits.buffer.density
acquisition.bits.buffer.headers
acquisition.bits.buffer.sampling_description
```

**Note that density is empty**

Lets see the size of the data and trajectory and deduce who is what

```matlab
K>> size(acquisition.bits.buffer.data)

ans =

        2554          48           1           4

K>> size(acquisition.bits.buffer.trajectory)

ans =

           3        2554          48
```

data :

- 2554 -> readout length **sRO**
- 48 -> spiral interleaves **sProj**
- 4 -> channel **nCh**

trajectory :

- 2554 -> readout length **sRO**
- 48 -> spiral interleaves **sProj**
- 3 -> kx/ky/kz trajectory

**However, we know that it is a 2D-spiral acquistion. Why do we have a kz trajectory ?**

We have to investigate, let's plot the first spiral interleaves of the trajectory and the "kz trajectory" :

```matlab
figure; 
subplot(2,1,1);plot(acquisition.bits.buffer.trajectory(1,:,1),...
										acquisition.bits.buffer.trajectory(2,:,1));
subplot(2,1,2);plot(acquisition.bits.buffer.trajectory(3,:,1));
```

So the first 2 dimensions are the kx/ky trajectory for sure.

Finding the last one is a bit tricky, it is the density compensation  function used to compensate the oversampling of the kspace during the  gridding reconstruction.

We can ask ourself why it is not store in the empty **density**. Short answer, in 2010 it was used like that and some C++ gadgets (like the [GriddingReconGadget](https://github.com/gadgetron/gadgetron/blob/master/gadgets/mri_noncartesian/GriddingReconGadgetBase.hpp)) know that the 3rd dimension store the **density** for 2D non-Cartesian acquisition.



### Correct the reader

We want to correct our reader to take into account this "feature". Let's dive in the gadgetron-matlab. In **gadgetron-matlab/+gadgetron/+external/+readers** folder you can find all the reader available to read the data. We will create a new one based on the **read_recon_data.m** which is the one used when data are sent after the **BucketToBuffer gadget**.

Copy the **read_recon_data.m** to a new file **read_recon_data_and_separated_density_weights.m** and add this function at the end which separate the trajectory/density.

```matlab
function buffer = separate_traj_and_dcw(buffer) % retrocompatibility
    if(~isempty(buffer) && isempty(buffer.density) && ~isempty(buffer.trajectory))
        if(buffer.headers.trajectory_dimensions(1) == 3)
            buffer.density = buffer.trajectory(3,:,:);
            buffer.trajectory(3,:,:)=[];	  	    
            buffer.headers.trajectory_dimensions=... 	   
            			2*ones(size(buffer.headers.trajectory_dimensions));
        end
    end
end
```

We now need to call this function in the **read_recon_bit** function (available in this file) for both the buffer and the reference :

```matlab
function recon_bit = read_recon_bit(socket)
    recon_bit.buffer = read_recon_buffer(socket);
    recon_bit.buffer = separate_traj_and_dcw(recon_bit.buffer);
    recon_bit.reference = gadgetron.external.readers.read_optional(socket, @read_recon_buffer);
    recon_bit.reference = separate_traj_and_dcw(recon_bit.reference);
end
```

Our new reader is ready, in order to use it during the call we can use the **connection.add_reader** method of the connection object before reading the acquisition.

```matlab
function GT_reco_nonCart(connection)
disp("GT_reco_nonCart was called.")

connection.add_reader(uint32(gadgetron.Constants.RECON_DATA), @gadgetron.external.readers.read_recon_data_and_separated_density_weights);

next_acquisition = @connection.next;
acquisition = next_acquisition(); % Call input function to produce the next 
end
```

With that modification we now have a clean acquisition object :

```matlab
K>> size(acquisition.bits.buffer.density)

ans =

          1          2554           48

K>> size(acquisition.bits.buffer.trajectory)

ans =

           3        2554          48
```



### Conclusion for trajectory

We are able to read the non-cartesian data in matlab. As we saw,  non-cartesian acquisition are often not well tagged/filled and requires  to check the data/trajectory.



## Reconstruction of non-Cartesian data using BART



### Data format in BART

We need to reshape the data according to the BART convention **[1 Readout Interleave channel]**

```matlab
matrice = acquisition.bits.buffer.data;
[sRO, sProj, ~, nCh] = size(matrice);
matrice = reshape(matrice,1,sRO,sProj,nCh);
```

For the trajectory, BART requires **[3 Readout Interleave channel]**. Our trajectory only has is equal to 2 along the first dimension because it is a 2D acquisition. We will just add zeros for the kz trajectory.  We also need to scale the data accordingly.

```matlab
trajtmp = acquisition.bits.buffer.trajectory;
% 3D traj : [3,sizeR, proj] (with zero if 2D)
traj = zeros(3,size(trajtmp,2),size(trajtmp,3));
traj(1:2,:,:)=trajtmp;
traj = traj*connection.header.encoding.encodedSpace.matrixSize.x; % scaling 1/FOV unit
```



### Simple gridding Adjoint

Multiple possibilities are available under BART to perform non-Cartesian  reconstruction. We will first work with the more obvious command **nufft**  for non-uniform fast fourier transform.

The standard gridding is called with the option -a for adjoint  reconstruction. The gridding operation is performed for each channel. We will do a sum-of-square reconstruction after that using the command `rss` of bart and then plot the results;

```matlab
agrid = bart('nufft -a', traj,matrice);
agrid = bart('rss $(bart bitmask 3)',agrid);
figure; imshow(agrid,[]);
```

**Image is blurred !**

This is due to the oversampling of the low frequency in the k-space. To compensate this effect we can use the **density** field. We need to multiply each point in the kspace by a weight.

```matlab
dcf = repmat(acquisition.bits.buffer.density,[1 1 1 nCh]);

agrid = bart('nufft -a', traj,matrice.*dcf);
agrid = bart('rss $(bart bitmask 3)',agrid);
figure; imshow(agrid,[]);
```

**Much better !**

The adjoint gridding operation is fast because it is not an iterative reconstruction, however it require to know the density. Depending on  your trajectory, you can either know an analytical solution or use the  implementation of this paper [![DOI](https://camo.githubusercontent.com/0574f5a1e1ea470700ce15b92b5d184cbcccd3f3/68747470733a2f2f7a656e6f646f2e6f72672f62616467652f444f492f31302e313030322f6d726d2e32333034312e7376673f73616e6974697a653d74727565)](https://doi.org/10.1002/mrm.23041)available [here](https://www.ismrm.org/mri_unbound/sequence.htm) for matlab and or a WIP in [a C++ gadget under Gadgetron](https://github.com/gadgetron/gadgetron/pull/845).



### Iterative gridding Inverse

An other way to do the nufft is to use the option **-i** rather than **-a** and will compensates for density differences in k-space  [![DOI](https://camo.githubusercontent.com/64c4fe89b54738c422590e14910524069c33d2f9/68747470733a2f2f7a656e6f646f2e6f72672f62616467652f444f492f31302e313030322f6d726d2e32323435332e7376673f73616e6974697a653d74727565)](https://doi.org/10.1002/mrm.22453)

```matlab
igrid = bart('nufft -i -c', traj,matrice);
igrid = bart('rss $(bart bitmask 3)',igrid);
figure; imshow(igrid,[]);
```

Image is not anymore blurred and results is suppose to be better.

Should i use the adjoint (with density) or iterative methode ?

- If you want to be fast (real-time imaging) the adjoint is faster.
- For 3D trajectories, the inverse nufft might not converge.
- If the reconstruction is not converging in nufft, it will not  converge in the pics tool and you will also need to pass the weight to  the function using the option **-p**



## Send the data

Now we have 2 images (adjoint and inverse) and we want to send the results to gadgetron.

First we will permute the data accordingly to the gadgetron convention : [channel, readout, phase encoding, slice encoding]

```matlab
%% Permute data : channel, readout, PE, SE
img_to_send{1}=permute(igrid,[4, 1, 2, 3]);
img_to_send{2}=permute(agrid,[4, 1, 2, 3]);
```

In order to send the image we have to create an **image** object with the function

```matlab
image = gadgetron.types.Image.from_data(data, reference)
```

where data is our image and reference is the header of one readout. We will use this function to extract it :

```matlab
%% suppport functions
function reference = reference_header(recon_data)
    % We pick the first header from the header arrays - we need it to initialize the image meta data.    
    reference = structfun(@(arr) arr(:, 1)', recon_data.bits.buffer.headers, 'UniformOutput', false);
end
```

In order to send the 2 images we will loop through img_to_send and  send them one-by-one and also specify the type of image, here magnitude.

```matlab
for ii=1:length(img_to_send)
    image = gadgetron.types.Image.from_data(img_to_send{ii}, reference_header(acquisition));
    image.header.image_type = gadgetron.types.Image.MAGNITUDE;
    
    disp("Sending image to client.");
    connection.send(image);
end
```

**Our gadget is now completed**.

You should be able to get a .h5 file with 2 images inside. You can either visualize it using the **ismrmrdviewer** or the matlab support functions of the repository :

```matlab
img = read_image_h5();
figure; imshow(img(:,:,1),[])
```



## Conclusion

During this lecture, you learn how to deal with non-Cartesian  datasets (particularly the trajectory)  reconstruct them using the BART  toolbox and send the image back to Gadgetron.

If you want to obtain more information about BART, they launched a [webinar](https://github.com/mrirecon/bart-webinars) a few weeks ago which cover a lot of the BART toolbox possibilities including the non-Cartesian recontruction.

If you don't want to use BART, there is also a lot of different  toolbox available to reconstruct non-Cartesian imaging for matlab :

- [gpuNUFFT](https://github.com/andyschwarzl/gpuNUFFT)
- [IRT toolbox](http://web.eecs.umich.edu/~fessler/code/mri.htm)
- [nufft_3D](https://github.com/marcsous/nufft_3d)

Other possibilities for non-Cartesian acquisition is available :

- Read the acquisition, fill the trajectory field and send back the  data to gadgetron in order to use the C++ gadget of the gridding

  
