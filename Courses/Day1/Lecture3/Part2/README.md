# Lecture 3 : Basic reconstruction using Python (2/3)

Title : Basic reconstruction using Python

Schedule : June 11, 2020 | 16:00-17:00 

Speaker: Valéry Ozenne

## Summary

 - [A brief description of the class used to store readout, kspace or image data](#)
    - [Readout](#les-issues)
    - [Kspace](#faq)
    - [Image](#liens)
 - [My First Data Buffered Gadget](#glossaire)
    - [Writing the Buffered Gadget](#les-issues)
    - [Compilation](#faq)
    - [Exercice 1: Fourier Transform using imsmrmrd-python-tool](#liens)
    - [Exercice 2: Fourier Transform using Sigpy](#liens)
    - [Exercice 3: Fourier Transform using BART](#liens)
    - [Exercice 4: Grappa reconstruction using PyGrappa](#liens)


## A brief description of the class used to store readout, kspace or image data

The data structures in the gadgetron vary during reconstruction. It is important to differenciate, the class or common structures 

* used to store a unit of readout that would feed into a buffer
* used to store a unit of data that would feed into a reconstruction
* used to store an array of reconstructed data

Each of them are defined in a C++ and have equivalent in Python. Additionnal structure are also present and you can create new one

### Readout

Le gadget python recevra deux messages associés qui contiennent le **AcquisitionHeader** et les données sous forme de matrice **hoNDArray< std::complex<float> >**.
En python le **hoNDArray** est la matrice multidimensionnel **ndarray** issue de la librairie numpy 

``` 
process(self, header, data):

```

```
print(type(header))

print(type(data))
```

### Kspace

In cartesian sampling, two gadgets play a fundamental role : AcquisitionAccumulateTriggerGadget and BucketToBufferGadget. 

These gadgets are used to buffer readouts in order to build the kspace. In MRI, the dimensions are very numerous:: 

* kx (RO)
* ky (E1)
* kz (E2)
* channels (CHA)
* average
* repetition
* segment
* contrast
* phase
* set
* slice (SLC)
* ...
 
By convention, in input the matrix size is [RO, CHA] and in output is [RO E1 E2 CHA N S SLC].
The dimensions **N** and **S** are chosen by the user. 

It is very interesting to position yourself after these gadgets where the kspaces data are automatically sorted, whether it is the calibration lines in parallel imaging or the lines sampled.   


The calibration data if present is accessible via the following structure:

```
buffer.ref.data  
buffer.ref.header
```

The fullysampled or undersampled data are accessible via the following structure:

```
buffer.data.data
buffer.data.header
```

Be cautious, the size of the headers is associated with the size of the data. Between them the headers are generally different, for example the position of the slicess change according to the SLC direction. We now have a hoNDarray acquisitionHeader with a matrix size of [E1 E2 N S SLC]. The headers being identical according to the direction of readout and for all channels.

 
### Image


### Writing the Buffered Gadget

Nous allons donc maintenant créer un nouveau gadget nommé `SimpleDataBufferedPythonGadget` dans un fichier appelé `my_first_buffered_data_gadget.py`

`

```
import numpy as np
import gadgetron
import ismrmrd
import logging
import time

def SimplePythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0

   for acquisition in connection:          
        
      
       connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")
```

And a new xml file named `external_python_buffer_tutorial.xml`

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
        
          <!-- EPI correction -->
     <gadget>
        <name>ReconX</name>
        <dll>gadgetron_epi</dll>
        <classname>EPIReconXGadget</classname>
     </gadget>

     <gadget>
        <name>EPICorr</name>
        <dll>gadgetron_epi</dll>
        <classname>EPICorrGadget</classname>
     </gadget>

     <gadget>
        <name>FFTX</name>
        <dll>gadgetron_epi</dll>
        <classname>FFTXGadget</classname>
     </gadget>

     <gadget>
        <name>OneEncodingSpace</name>
        <dll>gadgetron_epi</dll>
        <classname>OneEncodingGadget</classname>
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
        <property><name>N_dimension</name><value>contrast</value></property>
        <property><name>S_dimension</name><value>average</value></property>
        <property><name>split_slices</name><value>false</value></property>
        <property><name>ignore_segment</name><value>true</value></property>
     </gadget>

        <external>
            <execute name="my_first_data_buffered_python_gadget" target="SimpleDataBufferedPythonGadget" type="python"/>
            <configuration/>
        </external>
 
    </stream>

</configuration>
```

### Compilation 

Nothing to do.

### Reconstruction and visualisation

To run the reconstruction chain, you'll need to run Gadgetron, and the Gadgetron ISMRMRD client in two different terminal located in the same folder.

Start Gadgetron:
```bash
$ gadgetron
```

Run the ISMRMRD client: 
```bash 
$ gadgetron_ismrmrd_client -f Data/meas_MID00026_FID49092_cmrr_12s_80p_MB0_GP0.h5  -C external_python_tutorial.xml
```

You will see from the Gadgetron ISMRMRD client side :

``` bash
Gadgetron ISMRMRD client
  -- host            :      localhost
  -- port            :      9002
  -- hdf5 file  in   :      /home/valery/DICOM/2017-09-14_IBIO/meas_MID00026_FID49092_cmrr_12s_80p_MB0_GP0.h5
  -- hdf5 group in   :      /dataset
  -- conf            :      default.xml
  -- loop            :      1
  -- hdf5 file out   :      out.h5
  -- hdf5 group out  :      2020-05-19 15:44:55
This measurement has dependent measurements
  Noise : 16
Querying the Gadgetron instance for the dependent measurement: 66056_63650129_63650134_16
```


You will see from the Gadgetron server side :

```bash
[...]

```

### Exercice 1: Fourier Transform using imsmrmrd-python-tool


```python
import matplotlib.pyplot as plt
from ismrmrdtools import show, transform
```

```python
for acquisition in connection:
      
       #acquisition is a vector of a specific structure, we called reconBit 
       #print(type(acquisition[0]))

       for reconBit in acquisition:

           print(type(reconBit))
           # reconBit.ref is the calibration for parallel imaging
           # reconBit.data is the undersampled dataset
           print('-----------------------')
	   # each of them include a specific header and the kspace data
           print(type(reconBit.data.headers))
           print(type(reconBit.data.data))

           print(reconBit.data.headers.shape)
           print(reconBit.data.data.shape)
           
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)
```

we could set alternative names for acquisition and reconBit but then data, ref and data and headers are fixed and refered to a specific class.

```python
for lala in connection
  for lili in lala
      #use
      lili.ref.headers
      lili.ref.data
      lili.data.headers
      lili.data.data
      
```

### Exercice 2: Fourier Transform using BART
### Exercice 3: Fourier Transform using Sigpy
### Exercice 4: Grappa reconstruction using PyGrappa





