## Demo 1: MP2RAGE reconstruction

[Bucket demo](https://github.com/gadgetron/GadgetronOnlineClass/blob/master/Courses/Day3/Lecture2/Exercises-correction/bucket/Lecture%209%20%20Prototyping%20at%20the%20scanner%20with%20MATLAB%20%20part%202.md) (not demonstrated live -> homework for you!)

Simplicity often leads to use the gadget **BucketToBuffer** before calling Matlab. However in highly under-sampled cases, using the bucket is faster than loading the ReconData (Buffer) object. A good example is a sparse acquisition with a lot of un-acquired lines like Compressed-Sensing ([see this issue](https://github.com/gadgetron/gadgetron/issues/808)) :

To give some numbers of processing times on a typical PC, for a k-space size of : **Data dimensions [RO E1 E2 CHA N S SLC] : [320 320 240 64 2 1 1]** with an acceleration factor of 8.

- Sending the ReconData (Buffer) to Matlab : **213 sec**
- Sending the Bucket to Matlab then buffer  : **37 sec**

##### Buffer -> Enhancing steps to allow multiple dimensions

Working with the buffer can facilitate data management since k-space will come in a big and organized chunk. Dimensions of k-space can be manipulated from the configuration files with AcquisitionAccumulateTriggerGadget and BucketToBufferGadget. 

The complete configuration file can be found in the solutions. An excerpt here shows the stage of the Matlab gadget: 

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <version>2</version>

  <stream>

    <gadget>
      <dll>gadgetron_mricore</dll>
      <classname>AcquisitionAccumulateTriggerGadget</classname>
      <property name="trigger_dimension" value="repetition"/>
    </gadget>

    <gadget>
      <dll>gadgetron_mricore</dll>
      <classname>BucketToBufferGadget</classname>
      <property><name>N_dimension</name><value>contrast</value></property>
      <property><name>S_dimension</name><value>average</value></property>
      <property><name>split_slices</name><value>false</value></property>
      <property><name>ignore_segment</name><value>true</value></property>
      <property><name>verbose</name><value>true</value></property>
    </gadget>

    <external>
      <execute name="gadgetron.custom.MP2RAGE_bufferrecon" type="matlab"/>
      <configuration/>
    </external>

  </stream>

</configuration>
```



To design the **MP2RAGE_bufferrecon**, the example **buffer_recon.m** from the Gadgetron examples will be modified. Modifications are 

 1/Output complex images all the way through

 2/Compute the MP2RAGE image from the 2 echoes.

First, the generated images from the k-space need to remain complex. The **coil combination** and the MRD image created should be altered. During coil combination, the image phase needs to be calculated. A simple but robust phase calculation is inserted, considering the coil dimension being the 1st dimension:

```matlab
    function image = combine_channels_cplx(image)
        labs = sqrt(sum(square(abs(image.data)), 1));
        lphase = sum(angle(image.data).*abs(image.data),1)./labs;
        % combine mag and phase
        image.data=(labs).*exp(1i*lphase);
    end
```

And the images produced need to be complex as well, and loop over the extra dimensions (contrast in this case):

```matlab
function imageout = create_image(image)
            %init with an empty dataset imageout(1,1)=gadgetron.types.Image.from_data(zeros(128),ismrmrd.ImageHeader());
            for n=1:size(image.reference,1)
                for s=1:size(image.reference,2)
                    imageout(n,s) = gadgetron.types.Image.from_data(image.data(:,:,:,:,n,s), image.reference(n,s));
                    imageout(n,s).header.image_type = gadgetron.types.Image.COMPLEX;
            end %end loop n
        end % end loop s
    end
```
Then, sending all images requires also a loop, so that send_image_to_client.m is modified as follows:

```matlab
 function image = send_image(image)
        for n=1:size(image,1)
            for s=1:size(image,2)
  fprintf("Sending image %d/%d %d/%d to client.\n",n,size(image,1),s,size(image,2));
  connection.send(image(n,s));
            end
        end
    end
```

Eventually, computing the MP2RAGE image:

```matlab
function imageout = combine_echoes(image)
    % use 1st echo as template
    imageout=image(1,1);
    for s=1:size(image,2)
        multiFactor=mean(abs(image(2,s).data(:))); %scaling factor
        imageout(1,s).data=real((conj(image(1,s).data).*image(2,s).data-multiFactor)./(abs(image(1,s).data).^2+abs(image(2,s).data).^2+2*multiFactor));
    end
    % update series index 
    imageout(1,s).header.image_series_index=2;
end
```


The final MP2RAGE_bufferrecon gadget will look like this:

```matlab
function MP2RAGE_bufferrecon(connection)
disp("Matlab Buffer MP2RAGE reconstruction running.");

next = gadgetron.examples.steps.create_slice_from_recon_data(@connection.next);        
next = gadgetron.examples.steps.basic_reconstruction(next);
%output complex data
next = gadgetron.custom.steps.combine_channels_cplx(next);
next = gadgetron.custom.steps.create_ismrmrd_image_cplx(next);
next = gadgetron.examples.steps.send_image_to_client(next, connection);
%compute and output MP2RAGE
next = gadgetron.custom.functions.MP2RAGE_combineEchoes(next,connection.header);
next = gadgetron.examples.steps.send_image_to_client(next, connection);

tic, gadgetron.consume(next); toc
end
```



##### Image processing gadget

Finally, the MP2RAGE image reconstruction can be performed by existing Gadgetron gadgets and only the image processing step can be included in a Matlab gadget. This exercise aims at inserting an **image->image Matlab gadget** that accumulates the 2 incoming images and outputs the MP2RAGE image as an extra series.

Let us start over from a simple configuration file:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <version>2</version>
    <readers>
        <reader>
            <dll>gadgetron_mricore</dll>
            <classname>GadgetIsmrmrdAcquisitionMessageReader</classname>
        </reader>
        <reader>
            <dll>gadgetron_mricore</dll>
            <classname>GadgetIsmrmrdWaveformMessageReader</classname>
        </reader>
    </readers>
    <writers>
        <writer>
            <dll>gadgetron_mricore</dll>
            <classname>MRIImageWriter</classname>
        </writer>
    </writers>
    
    <stream>
        <gadget>
            <name>RemoveROOversampling</name>
            <dll>gadgetron_mricore</dll>
            <classname>RemoveROOversamplingGadget</classname>
        </gadget>

        <gadget>
            <name>AccTrig</name>
            <dll>gadgetron_mricore</dll>
            <classname>AcquisitionAccumulateTriggerGadget</classname>
        </gadget>

        <gadget>
            <name>Buffer</name>
            <dll>gadgetron_mricore</dll>
            <classname>BucketToBufferGadget</classname>
            <property>
                <name>split_slices</name>
                <value>true</value>
            </property>
        </gadget>

        <gadget>
            <name>SimpleRecon</name>
            <dll>gadgetron_mricore</dll>
            <classname>SimpleReconGadget</classname>
        </gadget>

        <gadget>
            <name>ImageArraySplit</name>
            <dll>gadgetron_mricore</dll>
            <classname>ImageArraySplitGadget</classname>
        </gadget>

        <gadget>
            <name>Extract</name>
            <dll>gadgetron_mricore</dll>
            <classname>ExtractGadget</classname>
        </gadget>

        <gadget>
            <name>ImageFinish</name>
            <dll>gadgetron_mricore</dll>
            <classname>ImageFinishGadget</classname>
        </gadget>
    </stream>
</configuration>
```

A new Matlab gadget is inserted as Image objects are created in the stream, after the ImageArraySplit gadget, before the Extract gadget:

```xml
<external>
   <execute name="gadgetron.custom.MP2RAGEcombination" type="matlab"/>
   <configuration/>
</external>
```

This new Matlab script will receive Image objects. We can even filter for these objects, to ensure stability.

```matlab
function next = passthrough_images(connection)

connection.filter('gadgetron.types.Image')
%init the accumulating array and a counter
allimages = gadgetron.types.Image.empty();
counter=0;

function accumulate()
        
    while true
        counter = counter+1;
        allimages(counter) = connection.next(); %get next image
        connection.send(allimages(counter));       %send it away immediatly
    end

end

tic, gadgetron.consume(@accumulate); toc
end
```

Let us create a function that can compute the MP2RAGE image:

```matlab
function MP2RAGE = MP2RAGE_combineEchos(img1, img2)
    multiFactor=mean(abs(img2(:)));  % for scaling
    MP2RAGE = real((conj(img1).*img2-multiFactor)...
        ./(abs(img1).^2+abs(img2).^2+2*multiFactor));

end
```

We want this function to produce the MP2RAGE combination once 2 images (the 2 'echoes') have been received. This terminal condition is inserted in the `while` loop:

```matlab
if counter==2 % terminal condition
    MP2RAGE = MP2RAGE_combineEchos(allimages(1).data,allimages(2).data);
    %use first image as template, just replace data
    allimages(1).data=MP2RAGE;
    %the data type changed from 'complex' to 'real'
    allimages(1).header.image_type = gadgetron.types.Image.REAL;
    %increment series index
    allimages(1).header.image_series_index=images(1).header.image_series_index+1;
    %send
    connection.send(allimages(1));
    break; 
end
```

Eventually, the script looks like this:

```matlab
function next = passthrough_images(connection)

connection.filter('gadgetron.types.Image')
%init the accumulating array and a counter
allimages = gadgetron.types.Image.empty();
counter=0;

function allimg = accumulate()

    while true
        counter = counter+1;
        allimages(counter) = connection.next(); %get next image
        connection.send(allimages(counter));       %send it away immediatly

        if counter==2 % terminal condition
            MP2RAGE = MP2RAGE_combineEchos(allimages(1).data,allimages(2).data);
            %use first image as template
            allimages(1).data=MP2RAGE;
            %the data type changes from 'complex' to 'real'
            allimages(1).header.image_type = gadgetron.types.Image.REAL;
            %increment series index
            allimages(1).header.image_series_index=images(1).header.image_series_index+1;
            %send
            connection.send(allimages(1));
            break; 
        end
	end

	allimg=allimages;
end

function MP2RAGE = MP2RAGE_combineEchos(img1, img2)
    multiFactor=mean(abs(img2(:)));  % for scaling
    MP2RAGE = real((conj(img1).*img2-multiFactor)...
        ./(abs(img1).^2+abs(img2).^2+2*multiFactor));

end

tic, gadgetron.consume(@accumulate); toc
end
```
