# Lecture 3.3 : Protyping at the scanner with MATLAB part 2

Title : Protyping at the scanner with MATLAB part 2

Schedule : June 25, 2020 | 16:00-17:00 

Speaker: Oliver Josephs

[DRAFT IN PREPARATION]

This lecture presents a real-world use of Gadgetron and MATLAB at the scanner.

## Context

We use Gadgetron within an Imaging Neuroscience centre. The typical work at the centre involves multiple subject studies (e.g. 20 participants) with scanning over a period of weeks to months per study. Several, different studies share the scanners so we need robust separation of application. Also for both smooth operation and as for _scientific_ reproducibility we have to provide a robust and tracable environment. Docker containers for standard environment and isolation between e.g. test and production studies. Git repositories on Github for tracability.

## Overview of hardware and software component overview

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

### Integration
- Software traceability
- MATLAB within Docker
- NVIDIA docker

For the external language interface 'execute' to work gadgetron has to be able to call a matlab binary (in batch mode).


(N.B. line continuation backslashes required at end of lines)

sudo docker create --name=example_container_name \\\
  --net=host \\\
  --privileged \\\
  -v /hostshare:/hostshare \\\
  -v /usr/local/MATLAB:/usr/local/MATLAB \\\
  -v /tmp/.X11-unix:/tmp/.X11-unix \\\
  --volume="$HOME/.Xauthority:/root/.Xauthority:rw" \\\
  -e DISPLAY \\\
  --gpus all \\\
  example_image_name
  
also, in Dockerfile, since not recognised in "docker create" command line(bug? fixed?):
env NVIDIA_VISIBLE_DEVICES=all
env NVIDIA_DRIVER_CAPABILITIES=all

gives access to GPU from container for Matlab figures.
  
- N.B. https://github.com/mathworks-ref-arch/matlab-dockerfile
 - Matlab installed _inside_ the container (e.g. for the cloud).
 - Mathworks' curated Dockerfiles, etc.
 - Dependencies, Licensing, Toolboxes, etc.
 
- "execute" MATLAB in docker; "connect" to MATLAB outside docker - debugger

### Optimisation for Fast Recon at the Scanner

- n_acquistions trigger
- passing buckets to MATLAB
- working with data and headers within MATLAB
- returning images to the scanner database
- Matlab multi-core processing
  - Implicit parallisation
      - LAPACK
      - Matlab vectorisation
      - MATLAB Parallel Toolbox
      - Kristoffer's functional programming paradigm steps
- IceGadgetron xml configs to get raw data and allow image database receipt
- github ismrmrd mrd handling

### If time permits
- Physiological waveform handling with Gadgetron and MATLAB
- Siemens pulse / ecg / breathing belt
- Timestamping circuitry
