import numpy as np
import gadgetron
import ismrmrd
import logging
import time
import matplotlib.pyplot as plt

from gadgetron.types.image_array import ImageArray
from ismrmrdtools import show, transform

#BART import
import os
import sys
path = os.environ["TOOLBOX_PATH"] + "/python/";
sys.path.append(path);
from bart import bart
import cfl

#SigPy import
import sigpy as sp
import sigpy.mri as mr
import sigpy.plot as pl

#pygrappa import
from pygrappa import grappa

def get_first_index_of_non_empty_header(header):
    # if the data is undersampled, the corresponding acquisitonHeader will be filled with 0 
    # in order to catch valuable information, we need to catch an non-empty header
    # using the following lines 
      
    print(np.shape(header))
    dims=np.shape(header)
    for ii in range(0,dims[0]):
       #print(header[ii].scan_counter)
       if (header[ii].scan_counter > 0):
         break
    print(ii)
    return ii


def send_reconstructed_images(connection, data_array,acq_header):
    # the fonction creates an new ImageHeader for each 4D dataset [RO,E1,E2,CHA]
    # copy information from the acquisitonHeader
    # fill additionnal fields
    # and send the reconstructed image and ImageHeader to the next gadget
    # some field are not correctly filled like image_type that floattofix point doesn't recognize , why ?
    
    dims=data_array.shape     

    base_header=ismrmrd.ImageHeader()
    base_header.version=2
    ndims_image=(dims[0], dims[1], dims[2], dims[3])
    base_header.channels = ndims_image[3]       
    base_header.matrix_size = (data_array.shape[0],data_array.shape[1],data_array.shape[2])    
    base_header.position = acq_header.position
    base_header.read_dir = acq_header.read_dir
    base_header.phase_dir = acq_header.phase_dir
    base_header.slice_dir = acq_header.slice_dir
    base_header.patient_table_position = acq_header.patient_table_position
    base_header.acquisition_time_stamp = acq_header.acquisition_time_stamp
    base_header.image_index = 0 
    base_header.image_series_index = 0
    base_header.data_type = ismrmrd.DATATYPE_CXFLOAT
    base_header.image_type= ismrmrd.IMTYPE_COMPLEX
    base_header.repetition=acq_header.idx.repetition
  
    I=np.zeros((dims[0], dims[1], dims[2], dims[3]))
    for slc in range(0, dims[6]):
             for n in range(0, dims[5]):
               for s in range(0, dims[4]):
                   I=data_array[:,:,:,:,s,n,slc]
                   base_header.image_type= ismrmrd.IMTYPE_COMPLEX
                   base_header.slice=slc              
                   image_array= ismrmrd.image.Image.from_array(I, headers=base_header)
                   connection.send(image_array)


def SimpleBufferedDataPythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0

   for acquisition in connection:
      
       #acquisition is a vector of structure called reconBit
       #print(type(acquisition[0]))

       for reconBit in acquisition:

           print(type(reconBit))
           # reconBit.ref is the calibration for parallel imaging
           # reconBit.data is the undersampled dataset
           print('-----------------------')
	   # each of them include a specific header and the kspace data
           print(type(reconBit.data.headers))
           print(type(reconBit.data.data))

           print(reconBit.data.headers.shape)
           print(reconBit.data.data.shape)
           
           # use get_first_index_of_non_empty_header() instead of 34
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)
           
           # 2D ifft
           im = transform.transform_kspace_to_image(reconBit.data.data, [0,1])


           plt.subplot(121)
           plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           plt.subplot(122)
           plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))
           

           plt.show()
 
      
       connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")

def BARTBufferedDataPythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0
   print("coucou")
   for acquisition in connection:
      
       #acquisition is a vector of structure called reconBit
       #print(type(acquisition[0]))

       for reconBit in acquisition:

           print(type(reconBit))
           # reconBit.ref is the calibration for parallel imaging
           # reconBit.data is the undersampled dataset
           print('-----------------------')
	   # each of them include a specific header and the kspace data
           print(type(reconBit.data.headers))
           print(type(reconBit.data.data))

           print(reconBit.data.headers.shape)
           print(reconBit.data.data.shape)
           
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)
           reference_header=reconBit.data.headers.flat[34]
                     
           np.save('/tmp/gadgetron/data', reconBit.data.data)

           try: 
              if reconBit.ref.data is not None:
                print("reference data exist")            
                np.save('/tmp/gadgetron/reference', reconBit.ref.data)
              else:
                print("reference data not exist")
           except:
              print("issue with reference data")
                     
           try:
              print("calling BART") 
              # 2D ifft in bart             
              im=bart(1, 'fft -iu 7',  reconBit.data.data)
           except:
              print("issue with BART")


           #plt.subplot(121)
           #plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           #plt.subplot(122)
           #plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))
           #plt.show()
           send_reconstructed_images(connection,im,reference_header)
 
      
       #connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")


def create_array_of_image_header(image,acq,  dims_header):

        headers_list = []
        base_header=ismrmrd.ImageHeader()
        base_header.version=2
        ndims_image=np.shape(image)
        base_header.channels = ndims_image[3]       
        base_header.matrix_size = (image.shape[0],image.shape[1],image.shape[2])
        print((image.shape[0],image.shape[1],image.shape[2]))
        base_header.position = acq.position
        base_header.read_dir = acq.read_dir
        base_header.phase_dir = acq.phase_dir
        base_header.slice_dir = acq.slice_dir
        base_header.patient_table_position = acq.patient_table_position
        base_header.acquisition_time_stamp = acq.acquisition_time_stamp
        base_header.image_index = 0 
        base_header.image_series_index = 0
        base_header.data_type = ismrmrd.DATATYPE_CXFLOAT
        base_header.image_type= ismrmrd.IMTYPE_MAGNITUDE
        
        for slc in range(0, dims_header[4]):
           for n in range(0, dims_header[3]):
              for s in range(0, dims_header[2]):                 
                     headers_list.append(base_header)

        array_headers_test = np.array(headers_list,dtype=np.dtype(object)) 
        array_headers_test=np.reshape(array_headers_test, (dims_header[2], dims_header[3], dims_header[4])) 
        
        return array_headers_test



def SigPyBufferedDataPythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0

   for acquisition in connection:
      
       #acquisition is a vector of structure called reconBit
       print(type(acquisition))

       for reconBit in acquisition:

           print(type(reconBit))
           # reconBit.ref is the calibration for parallel imaging
           # reconBit.data is the undersampled dataset
           print('-----------------------')
	   # each of them include a specific header and the kspace data
           print(type(reconBit.data.headers))
           print(type(reconBit.data.data))

           print(reconBit.data.headers.shape)
           print(reconBit.data.data.shape)
           
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)           
           
           reference_header=reconBit.data.headers.flat[34]

           dims=reconBit.data.data.shape
           im=np.zeros(dims, reconBit.data.data.dtype)
           for slc in range(0, dims[6]):
             for s in range(0, dims[5]):
               for n in range(0, dims[4]):
                    #catch 4D dataset [RO E1 E2 CHA] from [RO E1 E2 CHA N S SLC]
                    kspace=reconBit.data.data[:,:,:,:,n,s,slc]
                    # tranpose from [RO E1 E2 CHA] to [CHA E2 E1 RO]
                    ksp=np.transpose(kspace, (3, 2 , 1, 0))
                    # 2D ifft in bart 
                    F = sp.linop.FFT(ksp.shape, axes=(-1, -2))
                    I=F.H * ksp
		    #I is a 4D dataset, put back the data into 7D ndarray
                    im[:,:,:,:,n,s,slc]=np.transpose(I, (3, 2 , 1, 0)) 
                    #im is a 7D dataset

                    
                    image_array= ismrmrd.image.Image.from_array(np.transpose(I, (3, 2, 1, 0)), headers=reference_header)                                
                    connection.send(image_array)

           plt.subplot(121)
           plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           plt.subplot(122)
           plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))           

           plt.show() 
           #send_reconstructed_images(connection,im,reference_header)       
      
       #connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")






def PyGrappaBufferedDataPythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0

   reference=[]

   for acquisition in connection:
      
       #acquisition is a vector of structure called reconBit
       print(type(acquisition[0]))

       for reconBit in acquisition:

           print(type(reconBit))
           # reconBit.ref is the calibration for parallel imaging
           # reconBit.data is the undersampled dataset
           print('-----------------------')
	   # each of them include a specific header and the kspace data
           print(type(reconBit.data.headers))
           print(type(reconBit.data.data))

           print(reconBit.data.headers.shape)
           print(reconBit.data.data.shape)

           index= get_first_index_of_non_empty_header(reconBit.data.headers.flat)
           repetition=reconBit.data.headers.flat[index].idx.repetition 

           print(repetition)           
           
           reference_header=reconBit.data.headers.flat[0]

           try: 
              if reconBit.ref.data is not None:
                print("reference data exist")            
                np.save('/tmp/gadgetron/reference', reconBit.ref.data)
                reference=reconBit.ref.data
              else:
                print("reference data not exist")
           except:
              print("issue with reference data")

           dims=reconBit.data.data.shape
           kspace_data_tmp=np.zeros(dims, reconBit.data.data.dtype)
           for slc in range(0, dims[6]):
             for n in range(0, dims[5]):
               for s in range(0, dims[4]):
        
                 kspace=reconBit.data.data[:,:,:,:,s,n,slc]
                 calib=reference[:,:,:,:,s,n,slc]        
                
                 calib=np.squeeze(calib,axis=2)
                 kspace=np.squeeze(kspace,axis=2)
               
                 sx, sy,  ncoils = kspace.shape[:]
                 cx, cy,  ncoils = calib.shape[:]

                 # Here's the actual reconstruction
                 res = grappa(kspace, calib, kernel_size=(5, 5), coil_axis=-1)

                 # Here's the resulting shape of the reconstruction.  The coil
                 # axis will end up in the same place you provided it in
                 sx, sy, ncoils = res.shape[:]                
                 kspace_data_tmp[:,:,0,:,s,n,slc]=res

        
           # ifft, this is necessary for the next gadget        
           #image = transform.transform_kspace_to_image(kspace_data_tmp,dim=(0,1,2))
           im = transform.transform_kspace_to_image(kspace_data_tmp,dim=(0,1,2))
           
           
           plt.subplot(121)
           plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           plt.subplot(122)
           plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))
           

           plt.show()
           send_reconstructed_images(connection,im,reference_header)

           
 
      
       #connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")

