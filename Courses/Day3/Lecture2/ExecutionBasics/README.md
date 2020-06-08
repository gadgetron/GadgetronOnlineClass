# Matlab gadget insertion and execute or debug

Practice Matlab gadgets in 3 steps:

**1/ Insert a matlab passthrough gadget**

Let us consider a typical configuration file:

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

Now insert a Matlab gadget at the acquisition stage (after RemoveROOversampling):

```xml
<external>
   <execute name="gadgetron.examples.passthrough" type="matlab"/>
   <configuration/>
</external>
```

The passthrough Matlab function holds no filter and consumes connection next item:

```matlab
function passthrough(connection)
    connection.filter(@(~, ~) false);
    tic, gadgetron.consume(@connection.next); toc
end
```

**2/ Debug with a listening Matlab**

This part has been covered by Kristoffer Knudsen. As a reminder, we replace the Matlab gadget with an "external call" with the given port 18000:

```xml
<external>   
<!-- Connect to a running process on port 18000. -->
       <connect port="18000"/>
<configuration/>
</external>
```

In order to match the call, Matlab must be listening to the same port:

```matlab
 >>gadgetron.external.listen(18000,@gadgetron.custom.passthrough)
```

It is now possible to add a breakpoint in Matlab to halt the process and debug in the Matlab shell.

**3/ Retrieve Connection header and next item**

This exercise aims at creating an Acquisition passthrough function that prints the protocol name. Here is a simple passthrough:

```matlab
function next = passthrough_header(connection)

    acquisitions = gadgetron.types.Acquisition.empty();
    counter=0;
    
    function accumulate()
        while true   
            counter = counter+1;
            % get the next acquisition
            acquisitions(counter) = connection.next();
            % send it right away down the pipeline
            connection.send(acquisitions(counter));         
        end
    end
    
    tic, gadgetron.consume(@accumulate); toc

end
```

Note how variables `acquisitions` and `counter` are declared in the base function and updated in the nested function. 

At the beginning of the function, we can query the protocol  name from the global protocol header. While data (acquisition or image)  carry individual headers, the global protocol header is the key to  multiple parameters. It has been discussed during Day 2 by Vinai  Roopchansingh & J. Andrew Derbyshire. This header is automatically  appended to the "Connection" and available at any step as `connection.header`. Thus, before the `accumulate` declaration, add:

```matlab
protocolname =  connection.header.measurementInformation.protocolName; 
fprintf('Started processing %s \n',protocolname);
```

However, this function does not terminate naturally and will 'fail' once `connection.next()` returns empty. 

<!--Note: despite an error output, the 'consume' function handles this exception and all data previously send to the socket continue down the Gadgetron stream.-->

We want to stop the loop before that happens. In the while loop, insert:

```matlab
if acquisitions(counter).is_flag_set(acquisitions(1).ACQ_LAST_IN_MEASUREMENT)
	break; 
end
```

With this, our Acquisition passthrough is complete. It accumulates  acquisition objects, prints the protocol name and pass-on the  acquisitions.