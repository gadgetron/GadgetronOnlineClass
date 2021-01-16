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

In order to reconstruct non-Cartesian acquisition, we need both the rawdata and the trajectory. Hopefully, MRD dataset has fields to store the trajectory :

* **trajectory_dimensions** indicates the type of trajectory (2D,3D or 2D + density compensation function)
* **traj_** stores the trajectory

```
Trajectory, elements = head_.trajectory_dimensions*head_.number_of_samples 
[kx,ky,kx,ky.....]        (for head_.trajectory_dimensions = 2)
```

However, most of the time the **traj_** field is not fill by the scanner and a specific gadget is used to calculate the trajectory according to the sequence parameters (for example with the [SpiralToGenericGadget](https://github.com/gadgetron/gadgetron/blob/master/gadgets/spiral/SpiralToGenericGadget.cpp)).

For prototyping, it can be faster to fill the **traj_** field with matlab. We will see how to do that in this example "On the fly" in order to reduce the reconstruction time.

## Information required for demo

In this example we will use a 2D radial acquisition acquired by Stanislas Rapacchi acquired with the following regular full spoke trajectory (SamplingType = 0) :

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

 The dataset called **radial2D_LUNGS_REG160SPKS** is available here : https://doi.org/10.5281/zenodo.3906695



