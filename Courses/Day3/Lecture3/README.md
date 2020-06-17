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
- NVIDIA docker

For the external language interface 'execute' to work gadgetron has to be able to call a matlab binary (in batch mode).
Docker containers for standard environment and isolation between e.g. test and production.

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
  
also, in Dockerfile, since not recognised in command line(bug ?):
env NVIDIA_VISIBLE_DEVICES=all
env NVIDIA_DRIVER_CAPABILITIES=all

gives access to GPU from container for Matlab graphics.
  
  OR

- N.B. https://github.com/mathworks-ref-arch/matlab-dockerfile
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
