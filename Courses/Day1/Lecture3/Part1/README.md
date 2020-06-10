# Lecture 3 : Basic reconstruction using Python (1/3)

Title : Basic reconstruction using Python

Schedule : June 11, 2020 | 15:40-17:00 

Speaker: Valéry Ozenne

## Summary

 - [Foreword](#foreword)
 - [Installation](#installation)
 - [Sequence and Data](#sequence-and-data)
 - [Objectives](#objectives)
 - [A typical Python Gadget](#a-typical-python-gadget)
 - [My first Python Gadget](#my-first-python-gadget)
   - [Writing the gadget](#writing-the-gadget)
   - [Writing the XML chain](#writing-the-xml-chain)
   - [Compilation and installation](#compilation-and-installation)
   - [Reconstruction and visualisation](#reconstruction-and-visualisation)
   - [Exercice 1 : find the number of readout](#exercice-1--find-the-number-of-readout)
   - [Exercice 2 : display the matrix size](#exercice-2--display-the-matrix-size)
   - [Exercice 3 : display the AcquisitionHeader](#exercice-3--display-the-acquisitionheader)
   - [Exercice 4 : readout selection and corresponding encoding space](#exercice-4--readout-selection-and-corresponding-encoding-space)
   - [Exercice 5 : Matplotlib and Ghost Niquist correction](#exercice-5--matplotlib--ghost-niquist)
   - [Exercice 6 : Buffering](#exercice-6--buffering)
   - [First conclusion](#first-conclusion)
 

## Foreword 

The Gadgetron responds to two major issues in MRI:
- prototyping: how to develop a new reconstruction and associate it with an existing or developing sequence.
- deployment: how to deploy a sequence and reconstruction on several sites for a clinical study

The Gadgetron also offers software flexibility (choice of language used) and hardware flexibility (choice of reconstruction hardware: from simple PC to Cloud). Specific aera of research impose constraints on reconstruction time or latency. Typically deployment on clinical sites or interventional imaging are two scenarios where the use of C ++ will be preferable. For most of the other thematics, languages ​​such as Python or Matlab are more accessible and particularly adapted to our computing problems (ex: matrix calculation, linear algebra). Addionnally, Python is quite popular in image processing (itk, vtk) and in machine learing (keras, tensor flow). 

## Installation

To do the tutorial, you need to install two components:

* gadgetron
* python-gadgetron

Detailed installation instructions have been summarized [here](https://github.com/gadgetron/GadgetronOnlineClass/tree/master/Installation). But basically, on Ubuntu you need to run the following line:

```
sudo add-apt-repository ppa:gradient-software/experimental
sudo apt-get update
sudo apt-get install gadgetron-all
sudo pip3 install gadgetron
```

(Optional) The following toolboxes will be used at the end of the tutorial. You can skip this part at the beginning.

* [ismrmrd-python-tools](https://github.com/ismrmrd/ismrmrd-python-tools)
* [sigpy](https://github.com/mikgroup/sigpy-mri-tutorial)
* [pygrappa](https://github.com/mckib2/pygrappa)
* [ismrmrdviewer](https://github.com/ismrmrd/ismrmrdviewer)
* [ismrmrd-viewer](https://github.com/DietrichBE/ismrmrd-viewer)  (an alternative)
* [BART](https://github.com/mrirecon/bart)

You can install them using `pip3 install` or using the command `python3 setup.py install` after downloading the source or `make` for BART as follow. Nevertheless somes dependencies must be satisfied.

```
git clone https://github.com/ismrmrd/ismrmrd-python-tools.git
cd ismrmrd-python-tools
sudo python3 setup.py install

sudo pip3 install pygrappa
sudo pip3 install sigpy
```
## known issues

In WSL, there is a need for a X11 server for the python gadgets to print out. Error is : "couldn't connect to display ":0"
We recommand, this one for the fix: [vcxsrv](https://sourceforge.net/projects/vcxsrv/)

## Sequence and Data

The data are single-shot gradient-echo EPI acquisitions from the [CMRR sequence](https://www.cmrr.umn.edu/multiband/) acquired on a 3T Prisma from Siemens without multiband acceleration.

Data is available at this link:  [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3777994.svg)](https://doi.org/10.5281/zenodo.3777994)

Three datasets (including noise calibration and kspace) are available: 
- phantom, 12 slices, 3 repetitions, in-plane acceleration none, slice acceleration none   
- phantom, 12 slices, 3 repetitions, in-plane acceleration 2, slice acceleration none  

The data has been converted using **siemens_to_ismrmrd**, we will not discuss data conversion here. This will be the topics of the next lectures.

## Objectives

- to create new python gadget from scratch
- to create a new xml configuration file 
- data manipulation (readout, kspace, image)
- to become familiar with the Cartesian reconstruction pipeline
- to call BART from a Python gagdet
- to call SigPy from a Python gagdet
- to call pygrappa from a Python gagdet

## A typical Python Gadget


```python
import numpy as np
import gadgetron
import ismrmrd

def EmptyPythonGadget(connection):
   
   for acquisition in connection:
          
       # DO SOMETHING     
       connection.send(acquisition)
  

```
The function is responsible for receiving all messages from the previous gadget and for sending a new message to the next gadget using **connection.send()**
It may or may not interact with the information contained in the message.  

## My first Python Gadget

### Writing the gadget

Create a new directory named `GT_Lecture3` as you wish, for instance in `/home/participants/Documents/` and open two terminals at the location.

```
mkdir GT_Lecture3
cd GT_Lecture3
```

Create the file my_first_python_gadget.py then copy the previous function. 

```
We can add the following text before connection.send() that we are going through it.
print("so far, so good")
```


### Writing the XML chain 

We will now create a new xml file named `external_python_tutorial.xml`. Add the following content into `external_python_tutorial.xml`

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

  

</configuration>
```

To call our gadget, we have to add it to the reconstruction chain which is currently empty. For this add the following lines after the `` MRIImageWriter``

```xml
  <stream>  
        <external>
            <execute name="my_first_python_gadget" target="EmptyPythonGadget" type="python"/>
            <configuration/>
        </external> 
    </stream>
```

### Compilation and installation 

Nothing to do.

### Reconstruction and visualisation

To run the reconstruction chain, you'll need to run Gadgetron, and the Gadgetron ISMRMRD client in two different terminal located in the same folder.

Start Gadgetron:
```bash
$ gadgetron
```

> <img src="https://img.shields.io/badge/-_Warning-orange.svg?style=flat-square"/>
> Note that the gadgetron must be launched in the folder where external_python_tutorial.xml and my_first_python_gadget.py have been edited.

Run the ISMRMRD client: 
```bash 
$ gadgetron_ismrmrd_client -f path/to/meas_MID00026_FID49092_cmrr_12s_80p_MB0_GP0.h5  -C path/to/external_python_tutorial.xml
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

``` bash
gadgetron
05-19 15:44:53.650 INFO [main.cpp:49] Gadgetron 4.1.1 [0c29a9433eb8dd93426ddc318f249d38af7b3d39]
05-19 15:44:53.650 INFO [main.cpp:50] Running on port 9002
05-19 15:44:53.650 INFO [Server.cpp:25] Gadgetron home directory: "/usr/local"
05-19 15:44:53.650 INFO [Server.cpp:26] Gadgetron working directory: "/tmp/gadgetron/"
05-19 15:44:55.499 INFO [Server.cpp:42] Accepted connection from: ::ffff:127.0.0.1
05-19 15:44:55.499 INFO [ConfigConnection.cpp:113] Connection state: [CONFIG]
05-19 15:44:55.501 INFO [HeaderConnection.cpp:82] Connection state: [HEADER]
05-19 15:44:55.501 INFO [VoidConnection.cpp:38] Connection state: [VOID]
05-19 15:44:55.502 DEBUG [Stream.cpp:52] Loading Gadget NoiseSummary of class NoiseSummaryGadget from 
05-19 15:44:55.537 DEBUG [NoiseSummaryGadget.cpp:35] Noise dependency folder is /tmp/gadgetron/
05-19 15:44:55.538 DEBUG [Gadget.h:130] Shutting down Gadget ()
05-19 15:44:55.539 INFO [Core.cpp:76] Connection state: [FINISHED]
05-19 15:44:55.540 INFO [Server.cpp:42] Accepted connection from: ::ffff:127.0.0.1
05-19 15:44:55.544 INFO [ConfigConnection.cpp:113] Connection state: [CONFIG]
05-19 15:44:55.558 INFO [HeaderConnection.cpp:82] Connection state: [HEADER]
05-19 15:44:55.574 INFO [StreamConnection.cpp:75] Connection state: [STREAM]
05-19 15:44:55.575 DEBUG [Stream.cpp:64] Loading External Execute block with name my_first_python_gadget of type python 
05-19 15:44:55.597 INFO [External.cpp:69] Waiting for external module 'my_first_python_gadget' on port: 46825
05-19 15:44:55.603 INFO [Python.cpp:31] Started external Python module (pid: 11056).
/usr/lib/python3/dist-packages/h5py/__init__.py:36: FutureWarning: Conversion of the second argument of issubdtype from `float` to `np.floating` is deprecated. In future, it will be treated as `np.float64 == np.dtype(float).type`.
  from ._conv import register_converters as _register_converters
05-19 15:44:55.887 DEBUG [ext. 11056 my_first_python_gadget.EmptyPythonGadget] Starting external Python module 'my_first_python_gadget' in state: [ACTIVE]
05-19 15:44:55.887 DEBUG [ext. 11056 my_first_python_gadget.EmptyPythonGadget] Connecting to parent on port 46825
05-19 15:44:55.889 INFO [External.cpp:86] Connected to external module 'my_first_python_gadget' on port: 46825
so far, so good
so far, so good
[...]
so far, so good
so far, so good
05-19 15:44:58.966 DEBUG [ext. 11056 my_first_python_gadget.EmptyPythonGadget] Connection closed normally.
05-19 15:44:59.011 INFO [Core.cpp:76] Connection state: [FINISHED]

```


### Exercice 1 : find the number of readout

Add the following lines, the initialisation must be before the loop

```python
counter=0
counter=counter+1;
print(counter)
```

Save the python file and launch the client.

### Exercice 2 : display the matrix size

Add the following lines

```
import numpy as np
print(np.shape(acquisition.data))
```

### Exercice 3 : display the AcquisitionHeader

Add the following lines

```python
print(acquisition.active_channels)
print(acquisition.scan_counter)
```


### Exercice 4 : readout selection and corresponding encoding space

Get the repetion number and slice number using the following lines:

```python
slice = acquisition.idx.slice
repetition=  acquisition.idx.repetition
e1=acquisition.idx.kspace_encode_step_1
segment=acquisition.idx.segment
print(counter, " slice: ",slice , " rep: ", repetition, " e1: ", e1," segment: ",  segment)
```

Now we can add a filter using the following command before the loop:

```python
# We're only interested in repetition ==0  in this example, so we filter the connection. Anything filtered out in
# this way will pass back to Gadgetron unchanged.
connection.filter(lambda acq: acq.idx.repetition ==0)
```

Increase the selection

```python
connection.filter(lambda acq: acq.idx.repetition ==2 and acq.idx.slice ==0)
```

Increase the selection
```python 
connection.filter(lambda acq: acq.idx.repetition ==2 and acq.idx.slice ==0 and acq.is_flag_set(ismrmrd.ACQ_IS_REVERSE))
```

Increase the selection
```python 
connection.filter(lambda acq: acq.idx.repetition ==2 and acq.idx.slice ==0 and acq.is_flag_set(ismrmrd.ACQ_IS_REVERSE) and acq.is_flag_set(ismrmrd.ACQ_IS_PARALLEL_CALIBRATION))
```

Pick then the dataset with ACS calibration: `path/to/meas_MID00030_FID49096_cmrr_12s_80p_MB0_GP2.h5` and try again


### Exercice 5 : Matplotlib & Ghost Niquist

Copy and paste the previous function and call it EpiPythonGadget.

Usign the connection filter, filter the data with the FLAGS:ACQ_IS_PHASECORR_DATA 
Pick only the first slice, you will see 9 lines using the fully sampled dataset: `path/to/meas_MID00026_FID49092_cmrr_12s_80p_MB0_GP0.h5`:

```python
 counter:  1  scan_counter:  2  slice:  0  rep:  0  e1:  32  segment:  1
 counter:  2  scan_counter:  3  slice:  0  rep:  0  e1:  32  segment:  0
 counter:  3  scan_counter:  4  slice:  0  rep:  0  e1:  32  segment:  1
 counter:  4  scan_counter:  1190  slice:  0  rep:  1  e1:  32  segment:  1
 counter:  5  scan_counter:  1191  slice:  0  rep:  1  e1:  32  segment:  0
 counter:  6  scan_counter:  1192  slice:  0  rep:  1  e1:  32  segment:  1
 counter:  7  scan_counter:  2378  slice:  0  rep:  2  e1:  32  segment:  1
 counter:  8  scan_counter:  2379  slice:  0  rep:  2  e1:  32  segment:  0
 counter:  9  scan_counter:  2380  slice:  0  rep:  2  e1:  32  segment:  1
```

Now, we would like to compare the magnitude and phase of the kspace using Matplotlib.

First set the import

```python
#import matplotlib
#matplotlib.use('Qt4Agg')  
import matplotlib.pyplot as plt
```

Then, pick the first channel.

```
fid=np.abs(np.squeeze(acquisition.data[0,:]))
```

and plot the data. The reverse line are plot in red and normal in blue 

```python
if (acquisition.is_flag_set(ismrmrd.ACQ_IS_REVERSE)):
          plt.plot(fid, 'r')
       else:
          plt.plot(fid, 'b') 
       if (counter%3==0):  
          plt.show()
          plt.pause(2)
```

Note that when you close the matplotlib window, the reco continue to the next plot.

The lines are used to correct the Ghost-Niquist artefact (caused by gradient imperfection) by computing the phase difference between positive and negative readout after ifft in the readout direction. Such corrections has been implemented in C++ as well as the regridding. Please see Generic_Cartesian_Grappa_EPI.xml.

### Exercice 6 : Buffering

For the last exercice : copy and paste my_first_python_gadget.py into my_second_python_gadget.py

In order to do the buffering, we need to first find the dimension of the ksapce and to allocate the matrix.
The flexible header or **ISMRMRDHeader** include general information about the acquisition like **patientInformation**, **acquisitionSystemInformation** and **encoding** information.
The ISMRMRD format will be explained in the next lectures.


```python
h=connection.header

number_of_channels=h.acquisitionSystemInformation.receiverChannels   
   
encoding_space = h.encoding[0].encodedSpace
              
eNz = encoding_space.matrixSize.z
eNy = encoding_space.matrixSize.y
eNx = encoding_space.matrixSize.x

encoding_limits = h.encoding[0].encodingLimits

number_of_slices=encoding_limits.slice.maximum+1
number_of_repetitions=encoding_limits.repetition.maximum+1

print("[RO, E1, E2, CHA, SLC, REP ]: ", eNx, eNy  , eNz , number_of_channels, number_of_slices, number_of_repetitions)
```

Then we do the allocation using numpy

```python
mybuffer=np.zeros(( int(eNx),int(eNy), int(eNz), int(number_of_channels)),dtype=np.complex64)
```

Then in the loop, get the encoding index and compare the size of the buffer and the readout:

```
e1=acquisition.idx.kspace_encode_step_1
e2=acquisition.idx.kspace_encode_step_2
slice = acquisition.idx.slice
repetition=  acquisition.idx.repetition   

print(np.shape(acquisition.data))
print(np.shape(mybuffer[:,e1,e2,:])) 
```

There is an oversampling in readout direction by a factor of 2 in all Siemens acquisition.
Use `np.transpose` to buffer the data from `acquisition.data` in `mybuffer`.

### First Conclusion

This conclude the lecture on readout. Note that standard kspace processing step (removeOversampling, ghost niquist and BO corrections for EPI, coil compression...) have already been developped in python or in C++. There is no need to redoo it except for educational purpose. 







