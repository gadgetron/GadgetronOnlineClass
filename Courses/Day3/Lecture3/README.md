# Lecture 3.3 : Protyping at the scanner with MATLAB part 2

Title : Protyping at the scanner with MATLAB part 2

Schedule : June 25, 2020 | 16:00-17:00 

Speaker: Oliver Josephs

[DRAFT IN PREPARATION]

This lecture presents a real-world implementation of Gadgetron and MATLAB at the scanner.

## Overview of components

- Siemens scanner
- IceGadgetron
- MaRS
- Ethernet networking
- Separate Gadgetron Ubuntu PC
- Docker
- Gadgetron
- gadgetron-matlab
- Matlab (R2020a)
- Reconstruction code

## Topics

- Software traceability
- MATLAB within Docker
- "execute" MATLAB in docker; "connect" to MATLAB outside docker - debugger
- n_acquistions trigger
- passing buckets to MATLAB
- working with data and headers within MATLAB
- returning images to the scanner database
- MATLAB Parallel Toolbox with Kristoffer's functional programming paradigm steps
- IceGadgetron xml configs to get raw data and allow image database receipt
- github ismrmrd mrd handling

- (If time permits)
- Physiological waveform handling with Gadgetron and MATLAB
- Siemens pulse / ecg / breathing belt
- Timestamping circuitry
