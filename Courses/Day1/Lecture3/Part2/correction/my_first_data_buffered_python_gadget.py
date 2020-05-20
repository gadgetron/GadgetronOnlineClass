import numpy as np
import gadgetron
import ismrmrd
import logging
import time
import matplotlib.pyplot as plt

from ismrmrdtools import show, transform

def SimpleDataBufferedPythonGadget(connection):
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
           
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)
           
           im = transform.transform_kspace_to_image(reconBit.data.data, [0,1])


           plt.subplot(121)
           plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           plt.subplot(122)
           plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))
           

           plt.show()
 
      
       connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")


def SigpyDataBufferedPythonGadget(connection):
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
           
           repetition=reconBit.data.headers.flat[34].idx.repetition 
           print(repetition)
           
           im = transform.transform_kspace_to_image(reconBit.data.data, [0,1])


           plt.subplot(121)
           plt.imshow(np.abs(np.squeeze(reconBit.data.data[:,:,0,0,0,0,0])))
           plt.subplot(122)
           plt.imshow(np.abs(np.squeeze(im[:,:,0,0,0,0,0])))
           

           plt.show()
 
      
       connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")

