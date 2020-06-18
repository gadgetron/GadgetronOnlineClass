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

Gadgetron integration within imaging neuroscience centres. The typical work at the centres involves multiple subject studies (e.g. 20 participants) with scanning over a period of weeks to months per study. Several, different, ongoing studies share the same scanners so we need robust separation of application. Also for both smooth operation and as for _scientific_ reproducibility we have to provide a robust, portable and tracable environment. Docker containers for standard environment and isolation between ongoing studies, physics development and production studies. Git repositories on Github for tracability.

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

- overall function

```matlab
function epi(connection)

disp("Matlab EPI reconstruction running.")

%% Generally useful parameters and debugging switches
g = utils.extract_xml_parameters(connection.header);

g.M = utils.generate_TBR_matrix(g);

% Use parallel, data-queued, pipeline if available
g.Parallel = true;

% Use separate processing steps for the acc. acq.'s
Separate_steps = false;

% Produce graphical output
Display = true;

% Save nifti data volumes
Save_nifti = false;

% Send reconstucted images back to client
Send_images = true;

disp(['Num segs = ' num2str(g.SegPE)])
disp(['CAIPI = ' num2str(g.upl('CAIPI'))])


%% Set up parallel thread pool
p=gcp('nocreate');
if isempty(p)
    parpool('threads');
end

%% Set up processing chain

% Get the next data bucket from gadgetron
next = @connection.next;

% Bucket may be a sensitivity reference or an acc. acq. volume

% If it's a sensitivity reference, reconstruct it
next = steps.reconstruct_reference(next, g);

% if it's a sensitity reference volume compute unfolding matrices
next = steps.sense_prepare(next, g);

% Otherwise the bucket is an acc. acq.,

next = steps.extract_data(next, g);

if Separate_steps
    % TODO these do not handle the header correctly, yet
    next = steps.frequency_offset_correction(next, g);
    
    next = steps.reconstruct_1d(next, g);
    
    next = steps.fft2d_and_unfold(next, g);
else
    % To reduce data communication overhead, combine previous three steps
    next = steps.combined_reconstruction(next, g);
end

if Display
    next = steps.display_volume(next);
end

if Save_nifti
    next = steps.save_nifti(next, g);
end

if Send_images
    % Scanner seems to want 2D EPI by slice
    % but 3D EPI by volume
    if g.dimEncod(3) == 1 % 2D
        next = steps.mrm_slices(next, g);
    else % 3D
        next = steps.mrm_volume(next, g);
    end
        
    next = steps.send_to_client(next, connection);
end

%% Execute the processing chain
tic, gadgetron.consume(next); toc

%% End of reconstruction code
end

```

- passing buckets to MATLAB
```matlab
function next = reconstruct_reference(input, g)
%RECONSTRUCT_REFERENCE Reconstruct fully-encoded sensitivity reference data
%   Detailed explanation goes here

nCha    = g.nCha;                         % No. of coil channels used for acquisition
nFE     = g.dimEncod(1);                  % No. of frequency-encoded points in final image
nFEAcq  = g.upl('numSamples');            % Typically will be nFE * over-sampling factor of 2
nNav    = g.upl('numberOfNavigators');    % No. of phase reference echoes
AccPE   = g.AccFact(2);                   % Acceleration factor of EPI readout
% Why doesn't dimEncod reflect partial Fourier?
% nPEAcq  = g.dimEncod(2) / AccPE;          % No. of lines *acquired* (assuming no partial Fourier) in main (not ref.) EPI readout
Acc3D   = g.AccFact(3);                   % Acceleration factor in partition direction
nParAcq = g.dimEncod(3) / Acc3D;          % No. of partitions acquired

% Processing choices:
nav_smooth          = 10;           % Smoothing to be applied to navigators [k-space span]
nav_padFactor       = 2;            % Padding multiple for extrapolating navigator correction

    function retval = reconstruct_reference(bucket)
        
        if bucket.ref.count == 0 % this is a (hopefully, data) bucket. Don't handle it here.
            retval = bucket;
            return
        end
        
        % N.B. Re. segmentation: For acc. acq. there are g.SegPE segments; for
        % the reference there are g.SegPE * AccPE segments.
        % We assume that the reference segments are acquired sequentially.
        disp(['product=' num2str(nFEAcq*nCha*g.SegPE*AccPE*nParAcq*Acc3D)])
        disp(['size_bucket=' num2str(size(bucket.ref.data))])
        d.data=reshape(bucket.ref.data, nFEAcq, nCha, [], g.SegPE*AccPE, nParAcq, Acc3D);
        %         nRefETL = size(d,3); % Number of lines acquired in EPI Echo train
        
%         %% Frequency Offset Correction
%         % function data = frequency_offset_correction(data, FirstNav_Middle, TE, tAcq, echospaceSec, limits)
        d = utils.frequency_offset_correction(d, g.FirstNav_Middle  * 1e-6,...
            g.TE               * 1e-3,...
            g.tAcq             * 1e-6,...
            g.tEchospace       * 1e-6,...
            g.xml.encoding.encodingLimits.kspace_encoding_step_1);
        
        %% Recon reference
        
        d = utils.recon1d(d, g.M, nNav, nav_padFactor, nav_smooth);
        
        % Partial Fourier
        f1d=zeros([g.dimEncod(2) nFE nCha Acc3D*nParAcq],'like',single(1i));
        f1d(1:size(d.f1d, 1),:,:,:)=d.f1d;
        
        % f1d - Fully sampled reference volume in projection-space after TBR and
        % navigator-based phase-correction; used to calculate sensitivities.
        
        % vvv - Fully sampled reference volume now in image domain having performed
        % FFT along 1st (PE) and 4th (PAR) dimensions:
        vvv=fftshift(fft(fft(fftshift(f1d)),[],4));    % AccPE*nPEAcq, nFE, nCha, Acc3D*nParAcq
        
        % To match undersampled data vol dimension order, for nifti saving, display, etc.
        % nFE, AccPE*nPEAcq, nCha, Acc3D*nParAcq
        vvv=permute(vvv,[2 1 3 4]);
        
        retval=vvv;
        %             save -v7.3 -nocompression ref vvv
        
        % sss - sqrt of sum of squares recon of reference volume:
        %         sss=sqrt(sum(conj(vvv).*vvv,3));
        %         figure(2);montage(sss*7e1);figure(1); % Need to remove for online case
    end
next = @() reconstruct_reference(input());

end
```
- n_acquistions trigger
```xml
        <!-- Human seg 0 caipi 1 pf 6/8 -->
        <gadget>
            <dll>gadgetron_mricore</dll>
            <classname>AcquisitionAccumulateTriggerGadget</classname>
            <property name="trigger_dimension" value="n_acquisitions"/>
            <property>
                <name>n_acquisitions_before_trigger</name>
                <value>10912</value>
            </property>        
            <property>
                <name>n_acquisitions_before_ongoing_trigger</name>
                <value>2068</value>
            </property>        
        </gadget>
        
    <!--
        <external>
            <execute name="epi" type="matlab"/>
            <configuration/>
        </external>
    --> 
	
        <external>
            <connect port="18000"/>
            <configuration/>
        </external>
	
        <gadget>
            <dll>gadgetron_mricore</dll>
            <classname>FloatToUShortGadget</classname>
        </gadget>

```
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
