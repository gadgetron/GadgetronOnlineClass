# Lecture 9 : Prototyping at the scanner with MATLAB  part 2

Title : Prototyping at the scanner with MATLAB part 2

Schedule : June 25, 2020 | 16:00-17:00 

Speakers : Stanislas Rapacchi & Aurélien Trotier

## Summary

 - [Foreword](#foreword)

 - [Setup for demo](#Setup-for-demo)

 - [Bucket type](#Bucket-type)

 - [Sending back the data](#Sending-back-the-data)

 - [Conclusion](#Conclusion)

   

## Foreword

Various data types can be used in gadgetron. The data type send to matlab will depend of the gadget you use previously. For example if you send the data after the **AcquisitionAccumulateTriggerGadget** the data type in matlab will be : **bucket**. If you send the data after the gadget **BucketToBufferGadget** the data type will be **ReconData**. In this example we will work on the **bucket** type and how to convert it to a standard k-space.

## Setup for demo

First you need to create the gadgetron config file **demo_1_bucket.xml**. We put the **external** gadget after **AcquisitionAccumulateTriggerGadget**

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
      
        <external>
            <!-- Connect to a running process on port 18000. -->
            <connect port="18000"/>

            <!-- The configuration is sent to the external process. It's left pretty empty here. -->
            <configuration/>
        </external>
    </stream>
</configuration>
```

Then we will create a matlab function which will be called by Gadgetron : **GT_reco_bucket.m**

```matlab
function GT_reco_bucket(connection)
disp("GT_reco_nonCart was called.")
next_acquisition = @connection.next;

acquisition = next_acquisition(); % Call input function to produce the next 
end
```

This function is pretty empty but we want to prototype the reconstruction from there.
For prototyping we will work in matlab debug mode : 

* Put a breakpoint at the beginning of the matlab function.
* in matlab console -> `gadgetron.external.listen(18000,@GT_reco_bucket)`
* start gadgetron server in a console : `gadgetron`
* call gadgetron from the client (change the path of input/ouput/config file) : 

```
gadgetron_ismrmrd_client -f /home/atrotier/GITHUB/EDUC_GT_MATLAB/data/2DMP2RAGE.h5 -o /home/atrotier/GITHUB/EDUC_GT_MATLAB/data/out/out_2DMP2RAGE.h5 -C /home/atrotier/GITHUB/EDUC_GT_MATLAB/config/demo_1_bucket.xml
```

Matlab should stop the script at your breakpoint.

## Bucket type

In the **Bucket** type, data are stored under `acquisition.data.data`. You can check the size of the data either using the debug mode or printing it with `size(acquisition.data.data)`. Data are stored with size **[Readout size, Channel, number of readout in your bucket]**. The number of readout in bucket can change depending on the parameters of the **AcquisitionAccumulateTriggerGadget**.

We have to learn a little bit what this gadget does. It will accumulate the readout from the scanner until a certain point depending on the Measurement Data Header (MDH) flag of the readout and the `<property><name>trigger_dimension</name><value>repetition</value></property>`

For example, here we will accumulate the data until a readout is tag with **ACQ_LAST_IN_REPETITION**. If you have multiple repetitions in your scan the bucket will be sent to the next gadget everytime gadgetron see this tag. This tag is defined in the MR sequence, this is why it is important to label your readout with the MDH correctly to work with gadgetron.

Our dataset is an acquisitions with 2 contrasts. If we put `<property><name>trigger_dimension</name><value>contrast</value></property>`, 2 buckets will be sent. The data in each one will be equal to : [256, 4, 256]. For the following part, we will stay with the trigger_dimenion : repetition. Thus we have to bufferize the data (put the data at the right place in the k-space) also along the contrast dimension. 

First we will read the information to create the k-space at the right size. 

**Note :**

* the encodingLimits fieds start at 0. We add +1 because matlab index start at 1.
* We directly extract the number of channel from the data because the dataset has been coil compressed during one of the previous gadget.
* We are not creating the k-space with the standard dimension (We will do that later)

```matlab
sRO = connection.header.encoding.reconSpace.matrixSize.x;
sPE = connection.header.encoding.reconSpace.matrixSize.y;
sSE = connection.header.encoding.reconSpace.matrixSize.z;
nContrast = connection.header.encoding.encodingLimits.contrast.maximum;
maxDim = nContrast + 1;
nCh = size(acquisition.data.data,2);

kdata=zeros(sRO,nCh,sPE*sSE,maxDim); % initialize matrixwith zero
```

In order to bufferize the data we can either loop along the number of readout. It is easy to read but not efficient. The solution here is to use the [linear ordering](https://www.mathworks.com/help/matlab/ref/sub2ind.html) of matrix under matlab. If you find a faster way, please share it with the community. 

**Note :** After buffer, we permute the data to obtain a k-space with a size of **[sRO,sPE,sSE,nCh,1,contrast]**

```matlab
% buffer the data at the right place into kdata (faster than using
% bucket_to_buffer because of the sparse matrix)
kdata(:,:,sub2ind([sPE,sSE,maxDim],row,col,TI_idx))=acquisition.data.data;
kdata = permute(kdata,[1 3 2 4]);
kdata=reshape(kdata,sRO,sPE,sSE,nCh,1,[]); %% buffering the echo according to bart convetion [RO,E1,E2,CHA,MAP,CON]

```

Now you have a standard k-space and you can reconstruct the data with a fft :

```matlab
%% simple fft
im_fft = fftshift(ifft2(ifftshift(kdata)));

%% combine channnel
im_fft = sqrt(sum(abs(im_fft).^2,4));
figure;imshow(im_fft(:,:,2),[]);
```

At this step you are suppose to obtain an image of a phantom. The last step is to send the data back, 

### Sending back the data

here we will send an image object. We will use the **Image.from_data** method to easily create it. We need to pass 2 arguments, our image and the header :

* the method **Image.from_data** take as input an image with the dimension : **channel, readout, PE, SE** Here we will store our contrast dimension along the channel dimension of the image object.
* As second input we have to give one of the header associated to a readout. We used here the supporting function **reference_header** to read it from the acquisition. (you can add the function after the **end** of GT_reco_bucket)

The image object is created but we need to add the information about the type of MR data (magnitude, phase, ...). You can look at the 

```matlab
%% Permute data : channel, readout, PE, SE (here we store the contrast along channel)
img_to_send=permute(abs(im_fft),[6, 1, 2, 3, 4, 5]);

%% send image

image = gadgetron.types.Image.from_data(img_to_send, reference_header(acquisition));
image.header.image_type = gadgetron.types.Image.MAGNITUDE;

disp("Sending image to client.");
connection.send(image);
```

```matlab
%% suppport functions
function reference = reference_header(bucket_data)
    % We pick the first header from the header arrays - we need it to initialize the image meta data.    
    reference = structfun(@(arr) arr(:, 1)', bucket_data.data.header, 'UniformOutput', false);
end
```

If all goes well, a file called **out_2DMP2RAGE.h5** has been writing. You can look at it, either with ismrmrdviewer or loading the data under matlab using this function (and plotting the data with imshow for example) : 

```matlab
function img = read_image_h5(filename)
if nargin < 1
    [file, PATHNAME] = uigetfile('*.h5');
    filename = fullfile(PATHNAME,file);
end

S=hdf5info(filename);

if exist(filename, 'file')
    dset = ismrmrd.Dataset(filename, 'dataset');
else
    error(['File ' filename ' does not exist.  Please generate it.'])
end

% hdr = ismrmrd.xml.deserialize(dset.readxml);

disp(dset.fid.identifier)

S=hdf5info(filename);
attributes=S.GroupHierarchy(1).Groups(1).Groups(1).Datasets(1).Name;
dataset=S.GroupHierarchy(1).Groups(1).Groups(1).Datasets(2).Name;
header=S.GroupHierarchy(1).Groups(1).Groups(1).Datasets(3).Name;

img=hdf5read(filename,dataset);
img=squeeze(img);
end
```

### Conclusion

Most of the time we will use the gadget **BucketToBuffer** before calling matlab. However in some case using the bucket is faster than loading the ReconData object for example for sparse acquisition with a lot of line not read like Compressed-Sensing ([see this issue](https://github.com/gadgetron/gadgetron/issues/808)) :

For a kspace size of : **Data dimensions [RO E1 E2 CHA N S SLC] : [320 320 240 64 2 1 1]** with an acceleration factor of 8.

* Sending the ReconData (Buffer) to matlab : 213 sec
* Sending the Bucket to matlab then buffer  : 37 sec  