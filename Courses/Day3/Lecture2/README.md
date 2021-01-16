# Lecture 9 : Prototyping at the scanner with MATLAB part 1

Title : Prototyping at the scanner with MATLAB part 1

Schedule : June 25, 2020 | 15:00-16:00

Speakers : Stanislas Rapacchi & Aurélien Trotier

[TOC]

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

Replace line 16 : 

```boost::process::args={"-batch", "gadgetron.external.main"},'```

 by
 
 ```boost::process::args={"-nosplash", "-nodesktop", "-r", "\"gadgetron.external.main; exit\""},```
 
 and recompile gadgetron.

**Optional**

The following programm will be used at the end of the tutorial. You can skip this part at the beginning. [ismrmrdviewer](https://github.com/ismrmrd/ismrmrdviewer) [BART](https://github.com/mrirecon/bart)

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



## Sequence and Data

Data are available at this link [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3888658.svg)](https://doi.org/10.5281/zenodo.3888658) and **to complete**

You should found :

- A 2D MP2RAGE dataset
- A spiral dataset
- a radial dataset

The data has been converted with **siemens_to_ismrmrd**, we will not discuss data conversion here.

# Objectives

1. Setup Matlab and verify installation
2. [Introduction to Matlab-Gadgetron](Introduction)
   - Classes, packages in +folder, nested functions
   - Data types
3. [Matlab insertion and usage](ExecutionBasics)
   - Insert a passthrough
   - Debug with Matlab listening
   - Retrieve connection header and next item
4. [Demo1: Cartesian](Demo1_Cartesian)
   - Buffer -> Enhancing steps to allow multiple dimensions
   - Image processing gadget
5. [Demo2: Non-Cartesian](Demo2_nonCartesian)
   - Trajectory / dcf -> change reader part
   - Reconstruction using BART from Matlab
   - Add trajectory to acquisition and forward to Gadgetron GriddingGadget (**Not enough time**)

# Exercises

## Buffering the data under Matlab

The objective of this exercise is to reconstruct the 2DMP2RAGE.h5 dataset without the BucketToBuffer gadget. You have to buffer the data under Matlab (hints : use the linear indexing of Matlab).

A correction and detailled instruction is available in the corresponding **bucket** subfolder.

## Trajectory with matlab + nufft with gadgetron

The objective of this exercise is to reconstruct this dataset called **radial2D_LUNGS_REG160SPKS** and available here  https://doi.org/10.5281/zenodo.3906695 in Day-3/Lecture-2 

It is a 2D radial dataset without any information about the trajectory inside the .h5. You will have to :
* add the trajectory to each readout
* send back each readout one by one to gadgetron
* create a buffer and bucket then use the gadget `CPUGriddingReconGadget` 

**Supporting function for the trajectory**
```matlab
function K=compute_traj4bart(ADCres, Nspokes, SamplingType,TrajOffset)

% generate a radial trajectory with Nspokes lines.
% kloc_onesided=getpolar(Nspokes,ADCres);
% kloc_centered=kloc_onesided-ADCres/2-ADCres/2*1i-1-1i;

switch SamplingType
    case 0 % regular full spoke
        angleIncrement = pi / Nspokes;
    case 1 % golden angle full spoke
        angleIncrement = pi * (sqrt(5)-1)/2;
    case 2 % golden angle small version full spoke
        angleIncrement = pi * (3-sqrt(5))/2; 
    case 3 % regular half spoke
        angleIncrement = 2*pi / Nspokes;
    case 4 % golden angle half spoke
        angleIncrement = 2*pi * (sqrt(5)-1)/2;
    case 5% golden angle small version half spoke
        angleIncrement = 2*pi * (3-sqrt(5))/2; 
end

% between -.5 and .5
if(SamplingType<3)
   SpokeVector = linspace(-ADCres/2+1,ADCres/2,ADCres);
else
   SpokeVector = linspace(0,ADCres,ADCres);
end

% Compute the exact Fourier samples on the radial trajectory.

if(~exist('TrajOffset','var'))
    TrajOffset=0;
end

K = zeros([3,ADCres,Nspokes]);

 for s = 1:Nspokes
    cs = TrajOffset + s-1;
    K(1,:,s) = SpokeVector*cos(cs*angleIncrement);
    K(2,:,s) = SpokeVector*sin(cs*angleIncrement);
 end
end

```
