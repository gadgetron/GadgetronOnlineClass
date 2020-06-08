# Lecture 9 : Protyping at the scanner with MATLAB part 1

Title : Protyping at the scanner with MATLAB part 1

Schedule : June 25, 2020 | 15:00-16:00

Speakers : Stanislas Rapacchi & Aurélien Trotier

[TOC]

## 

## Foreword

The Gadgetron responds to two major issues in MRI:

- prototyping: how to develop a new reconstruction and associate it with an existing or developing sequence.
- deployment: how to deploy a sequence and reconstruction on several sites for a clinical study

For many, Matlab remains the environment of choice for rapid prototyping in signal and image processing. This session will target such needs.

Basic knowledge of Matlab is expected for this session. Advanced Matlab programming skills such as packaging, classes and nested function is not mandatory and can be easily understood on-the-fly. Matlab-Gadgetron uses both, and we hope this session will demystify these notions for those unfamiliar with them.

## 

## Installation

To do the tutorial, you need to install three components:

- MATLAB **R2018b and above** (Superior to R2017a is also possible but need a modification of gadgetron)
- [gadgetron](https://github.com/gadgetron/gadgetron)
- [gadgetron-matlab](https://github.com/gadgetron/gadgetron-matlab)

**Gadgetron**

Detailed installation instructions have been summarized [here](https://github.com/gadgetron/GadgetronOnlineClass/tree/master/Installation). But basically, on Ubuntu you need to run the following line:

```
sudo add-apt-repository ppa:gradient-software/experimental
sudo apt-get update
sudo apt-get install gadgetron-all
```

**Gadgetron-Matlab**

Detailed installation and how to use matlab is available [here](https://github.com/gadgetron/gadgetron/wiki/Using-Matlab-with-Gadgetron). Basically you can search and install **gadgetron** from the Matlab Add-On manager.

**Matlab installed in Windows and Gadgetron in WSL**

For a Windows Matlab installation to be visible from WSL, an extra  script is needed. Create a script file named 'matlab' (no extension!).  You can use nano or your preferred editor:

```
nano matlab
```

In it, copy:

```
#!/bin/bash
export WSLENV=GADGETRON_EXTERNAL_PORT:GADGETRON_EXTERNAL_MODULE
matlab.exe $@
```

And save the file 'matlab'. Make it executable:

```
sudo chmod u+x matlab
```

Move it to a proper place that is in your PATH:

```
mv matlab /usr/local/bin/matlab
```

Save. Once installed, we're good to go!

**Matlab version between R2017a and R2018a**

 **WARNING: the following has not been tested!**You need to install gadgetron from the source code and edit the file **gadgetron/connection/stream/external/Matlab.cpp**

Replace line 16 : `boost::process::args={"-batch", "gadgetron.external.main"},'`
 by
 `boost::process::args={"--nosplash", "--nodesktop", "-r",  "\"gadgetron.external.main; exit\""},`Recompile gadgetron.

**Optional**

The following programm will be used at the end of the tutorial. You can skip this part at the beginning. [ismrmrdviewer](https://github.com/ismrmrd/ismrmrdviewer) [BART](https://github.com/mrirecon/bart)

## 

## Testing your installation

To verify the Matlab-Gadgetron connection is working, one can type

```
gadgetron --info.
```

Matlab should be supported.

```
Gadgetron Version Info
  -- Version            : 4.1.1
  -- Git SHA1           : 74f1d293866bb46a7c75ccca3eb0ededb4911e72
  -- System Memory size : 32647 MB
  -- Python Support     : YES
  -- Matlab Support     : YES
  -- CUDA Support       : NO
```

More thoroughly, after installing Gadgetron it is always a good idea  to run the integration test. Here we will run the Matlab test.

To do so move to the folder **gadgetron/test/integration**/

Download all the datasets with :

```
python get_data.py
```

and then run the Matlab test with :

```
python run_tests.py cases/external_matlab_tiny_example.cfg
```

If it is working you will see an output with this indication at the end :

```
Test status: Passed

1 tests passed. 0 tests failed. 0 tests skipped.
```

## 

## Sequence and Data

We will use a 3D MP2RAGE sequence with a variable density poisson undersampling mask acquired on a 3T Prisma from Siemens.

Data is available at this link [![DOI](https://camo.githubusercontent.com/a5e1c3af3a977667df49db191e2786b56bc4a3c2/68747470733a2f2f7a656e6f646f2e6f72672f62616467652f444f492f31302e353238312f7a656e6f646f2e333737373939342e737667)](https://doi.org/10.5281/zenodo.3777994)[ SMASH](https://sh2hh6qx2e.search.serialssolutions.com/?rft_id=info:doi/10.5281/zenodo.3777994&sid=lama-browser-addon): **Need to be change**

One dataset (without noise calibration) is available:

- brain, 0.8mm isotropic, acceleration factor = 20.

The data has been converted with **siemens_to_ismrmrd**, we will not discuss data conversion here. This will be the object of the following readings.

## 

# Objectives

1. Setup Matlab and verify installation
2. Introduction to Matlab-Gadgetron
   - Classes, packages in +folder, nested functions
   - Data types
3. Matlab insertion and usage
   - Insert a passthrough
   - Debug with Matlab listening
   - Retrieve connection header and next item
4. Demo 1: MP2RAGE reconstruction
   - Bucket -> Show workflow latency difference
   - Buffer -> Enhancing steps to allow multiple dimensions
   - Reconstruction with BART (called from Matlab)
   - Image processing gadget
5. Demo 2: Non-Cartesian
   - trajectory / dcf -> change reader part
   - Reconstruction using BART from Matlab
   - Add trajectory to acquisition and forward to gadgetron GriddingGadget (**Not enough time**)

