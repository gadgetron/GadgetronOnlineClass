# Lecture 1.2 : Practical Introduction to Gadgetron

*Note: This is a work in progress, and the summary is preliminary.* 

Title : Practical Introduction to Gadgetron

Schedule : June 11, 2020 | 15:00-16:00 

Speaker: Kristoffer Langeland Knudsen

## Summary

 - [Running Gadgetron Reconstructions]
   - [The Gadgetron Server] Introduction to the Gadgetron process. 
   - [The Gadgetron Client] Introduction to the Gadgetron MRD client in particular, and MRD clients in general. 
   - [Controlling Gadgetron]
     - [Creating a Config File]
     - [DEMO: Running a reconstruction.] 
       - [Introduce 'The Dataset'] A fully sampled Cartesian dataset. We'll use it throughout the lecture to demo Gadget functionality. 
       - [Introduce 'The Config File'] A minimal reconstruction. We'll build on it throughout the lecture as we demo Gadget functionality.
       - [Introduce 'Acquisition'] Light introduction of the 'Acquisition' concept, and how it fits in the Gadgetron Environment.      
     - [Common Config File Structure] Config files commonly weaves data from k-space through image-space, with a variety of processing steps in between. 
 - [AccumulateTriggerGadget]
   - [Introduction to AccumulateTriggerGadget's Functionality]
   - [DEMO: AccumulateTriggerGadget] Update minimal reconstruction to accumulate AcquisitionBuckets from Acquisitions.
     - [Introduce 'AcquisitionBucket'] Light introduction of the 'AcquisitionBucket' concept.
 - [BucketToBufferGadget]
   - [Introduction to BucketToBufferGadget's Functionality]
   - [DEMO: BucketToBufferGadget] Update minimal reconstruction to fill k-space buffers using AcquisitionBuckets.
     - [Introduce: 'ReconBuffer'] Light introduction to the 'ReconBuffer' concept.
 - [SimpleReconGadget]
   - [DEMO: SimpleReconGadget] Update minimal reconstruction to perform inverse fft. 
     - [Introduce: 'Image'] Light introduction to the 'Image' concept.  
 - [Gadgetron Resources] Finding out what Gadgets do; finding the Gadgets you need.
   - [The Gadgetron Wiki] 
   - [The Google Group]
   - [Asking Questions]
   - [Reading the Source]
   
If time permits: 
 - [DEMO: Flesh out the Reconstruction]
   - [NoiseAdjustGadget]
   - [RemoveOOversamplingGadget]
   - [AutoScaleGadget]
