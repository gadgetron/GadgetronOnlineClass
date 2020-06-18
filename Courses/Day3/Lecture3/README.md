# Lecture 3.3 : Protyping at the scanner with MATLAB part 2

Title : Protyping at the scanner with MATLAB part 2

Schedule : June 25, 2020 | 16:00-17:00 

Speaker: Oliver Josephs

Affiliations:
- Wellcome Centre for Imaging Neuroscience, Functional Imaging Laboratory, UCL. https://www.fil.ion.ucl.ac.uk/
- Birkbeck-UCL Centre for Neuroimaging. https://bucni.pals.ucl.ac.uk/

[DRAFT IN PREPARATION]

This lecture presents a real-world use of Gadgetron and MATLAB at the scanner.

## Context

Gadgetron integration within imaging neuroscience centres. The typical work at the centres involves multiple subject studies (e.g. 20 participants) with scanning over a period of weeks to months per study. Several, different, ongoing studies share the same scanners so we need robust separation of application. Also for both smooth operation and as for _scientific_ reproducibility we have to provide a robust, portable and tracable environment. Docker containers for standard environment and isolation between ongoing studies, physics developmentcand production studies. Git repositories on Github for tracability.

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

## Topics covered

### Integration
- Software traceability
- MATLAB within Docker
- NVIDIA docker

For the external language interface 'execute' to work gadgetron has to be able to call a matlab binary (in batch mode).

(N.B. line continuation backslashes required at end of lines)

```
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
```

also, in Dockerfile, since not recognised in "docker create" command line(bug? fixed?)
```
env NVIDIA_DRIVER_CAPABILITIES=all
```
gives access to GPU from container for Matlab figures. (https://github.com/NVIDIA/nvidia-container-runtime)
  
- N.B. https://github.com/mathworks-ref-arch/matlab-dockerfile
 - Matlab installed _inside_ the container (e.g. for the cloud).
 - Mathworks' curated Dockerfiles, etc.
 - Dependencies, Licensing, Toolboxes, etc.
 
- "execute" MATLAB in docker; "connect" to MATLAB (inside or) outside docker for debugger.

### Matlab software development framework

- Built on Kristoffer's example reconstruction by extending on 
  - Source tree with recon .m and .xml; +steps and +utils directories.

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

## Conclusion
- Have built this with long term on-going collaboration with others.
- If you have Matlab knowledge and develop, please collaborate and feedback.
- Hangouts every Friday, 3pm CET. Videoconference link posted on https://groups.google.com/forum/#!forum/gadgetron.
