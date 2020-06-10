import numpy as np
import gadgetron
import ismrmrd
import logging
import time
import io
import os

# ismrmrd_to_nifti
import sys
sys.path.append('/home/valery/Dev/ismrmrd_to_nifti')
from python_version import extract_ismrmrd_parameters_from_headers as param, flip_image as fi, set_nii_hdr as tools
import nibabel as nib


def IsmrmrdToNiftiGadget(connection):
    
    #get header info

    hdr=connection.header

    for acquisition in connection:         
        print("IsmrmrdToNifti, process ... ")
        print(np.shape(acquisition.data))
        image = np.abs(acquisition.data.transpose(3,2,1,0))

        # Rescale
        #img_scale=(np.abs(image)-np.amin(np.abs(image)))* 2^12*0.5/(np.amax(np.abs(image))-np.amin(np.abs(image)));

        ndim = image.shape
        print("IsmrmrdToNifti, receiving image array of shape ", ndim)
        print("IsmrmrdToNifti, receiving image head :", acquisition)

        ## Create parameters for set_nii_hdr et xform_mat
        h = param.extract_ismrmrd_parameters_from_headers(acquisition, hdr)
        print("IsmrmrdToNifti, computed Nifti parameters : ", h)

        ## Get crop image, flip and rotationate to match with true Nifti image
        img = image[:,:,:,0].transpose(1, 0, 2)

        ## Create nii struct based on img
        nii_empty = nib.Nifti1Image(img, np.eye(4))
        pf = {"lefthand":0}
        h2 =[]
        h2.append(h)

        ## Compute nifti parameters
        [nii_filled, h3] = tools.set_nii_hdr(nii_empty, h2, pf)

        ## Save image in nifti format
        output_path = os.path.join('/tmp/gadgetron/',hdr.measurementInformation.measurementID + '_' + hdr.measurementInformation.protocolName+'_nifti_manon_gadgetron.nii.gz')
        nib.save(nii_filled, output_path)
        print(output_path)
        print("Nifti well saved")

        # print data infos
        print("-------------------------------------------------------------------------")
