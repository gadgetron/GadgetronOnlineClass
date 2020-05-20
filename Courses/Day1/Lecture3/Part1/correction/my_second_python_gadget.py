import numpy as np
import gadgetron
import ismrmrd
import logging
import time

def BufferPythonGadget(connection):
   logging.info("Python reconstruction running - reading readout data")
   start = time.time()
   counter=0

   h=connection.header

   number_of_channels=h.acquisitionSystemInformation.receiverChannels   
   
   encoding_space = h.encoding[0].encodedSpace
   encoding_limits = h.encoding[0].encodingLimits  
            
   eNz = encoding_space.matrixSize.z
   eNy = encoding_space.matrixSize.y
   eNx = encoding_space.matrixSize.x

   number_of_slices=encoding_limits.slice.maximum+1
   number_of_repetitions=encoding_limits.repetition.maximum+1

   print("[RO, E1, E2, CHA, SLC, REP ]: ", eNx, eNy  , eNz , number_of_channels, number_of_slices , number_of_repetitions)  
   

   mybuffer=np.zeros(( int(eNx)*2,int(eNy), int(eNz), int(number_of_channels)),dtype=np.complex64)

   # We're only interested in repetition ==0  in this example, so we filter the connection. Anything filtered out in
   # this way will pass back to Gadgetron unchanged.
   connection.filter(lambda acq: acq.idx.repetition ==2 and acq.idx.slice ==0 )

   for acquisition in connection:          
        
       counter=counter+1
     
       e1=acquisition.idx.kspace_encode_step_1
       e2=acquisition.idx.kspace_encode_step_2
       slice = acquisition.idx.slice
       repetition=  acquisition.idx.repetition   

       print(np.shape(acquisition.data))
       print(np.shape(mybuffer[:,e1,e2,:])) 
       mybuffer[:,e1,e2,:]=np.transpose(acquisition.data,(1,0))

       
       #print(" counter: ", counter, " scan_counter: ", acquisition.scan_counter, " slice: ",slice , " rep: ", repetition, " e1: ", e1," segment: ",  segment)
       connection.send(acquisition)

   logging.info(f"Python reconstruction done. Duration: {(time.time() - start):.2f} s")




