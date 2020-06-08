# Introduction to Matlab environment

```
### Aim: Review formalism of Matlab-Gadgetron scripts and code
```

- **Classes, packages in +folder, nested functions**

Matlab can package a set of functions and classes in a folder starting with a `+` sign. By adding the parent folder in Matlab PATH, the whole package is exposed and can be called subsequently. If the Gadgetron Add-on has been added, from the `+gadgetron` folder, the class Constants can be called in Matlab:

```matlab
 classdef Constants   
    properties (Access = public, Constant)
        % Message identifiers
        FILENAME      = uint16(1);
        CONFIG        = uint16(2);
        HEADER        = uint16(3);
        CLOSE         = uint16(4);
        TEXT          = uint16(5);
        QUERY         = uint16(6);
        RESPONSE      = uint16(7);
        ERROR         = uint16(8);
        
        ACQUISITION   = uint16(1008);
        IMAGE         = uint16(1022);

        RECON_DATA    = uint16(1023);
        IMAGE_ARRAY   = uint16(1024);

        WAVEFORM      = uint16(1026);

        BUCKET        = uint16(1050);
        BUNDLE        = uint16(1051);
	end
end
```
Given the public properties of Constants:

```
>>gadgetron.Constants.ERROR

ans =

  uint16

   8
```

A lot of **nested functions** are employed in the following demonstration. Nested functions have a limited scope of definition.

```matlab
function next = noise_adjust(input, header)

noise_matrix        = [];

function transformation = calculate_whitening_transformation(data)
    covariance = (1.0 / (size(data, 1) - 1)) * (data' * data); 
    transformation = inv(chol(covariance, 'upper'));
end

function acquisition = apply_whitening_transformation(acquisition)
    acquisition.data = acquisition.data * noise_matrix; 
end

function acquisition = handle_noise(acquisition)    
        if acquisition.is_flag_set(acquisition.ACQ_IS_NOISE_MEASUREMENT)
   noise_matrix = calculate_whitening_transformation(acquisition.data);
        else 
   acquisition = apply_whitening_transformation(acquisition);
        end
end

next = @() handle_noise(input());

end
```

The variable `noise_matrix` is shared among all nested functions. One function can define it, while another can use it internally. Its scope remains limited to the processing of the base function `noise_adjust`.

 note: safeguards  have been remove for clarity, they are the user's responsibility!

- **Data types and available input(in)/output(out)**
  - acquisition  (in&out)     -> self-gating / add trajectory / sliding window / filter
  - bucket          (in)             -> sparse matrix (CS) / non-Cartesian acquisition
  - buffer           (in)             -> sorted acquisition data (assuming Cartesian)
  - imagearray  (in)             -> image processing (mapping)
  - image            (in&out)   -> masking, segmentation

These objects contain multiple objects inside, including:

​           Data, Headers, Waveforms, Metadata, Trajectory, Density

We will not review all these objects, their definitions, readers and writers (when complete) being available within the code.