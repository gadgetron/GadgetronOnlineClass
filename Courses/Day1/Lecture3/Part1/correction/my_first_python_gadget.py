import numpy as np
import gadgetron
import ismrmrd

#import matplotlib
#matplotlib.use('Qt4Agg')
import matplotlib.pyplot as plt


def EmptyPythonGadget(connection):
   counter=0

   # We're only interested in repetition ==0  in this example, so we filter the connection. Anything filtered out in
   # this way will pass back to Gadgetron unchanged.
   connection.filter(lambda acq: acq.idx.repetition ==2 and acq.idx.slice ==0 and acq.is_flag_set(ismrmrd.ACQ_IS_REVERSE) )

   for acquisition in connection:
          
       # DO SOMETHING   
       print("so far, so good")  
       counter=counter+1;
       print(counter)
       #print(np.shape(acquisition.data))
       print(acquisition.active_channels)
       print(acquisition.scan_counter)
       slice = acquisition.idx.slice
       repetition=  acquisition.idx.repetition
       e1=acquisition.idx.kspace_encode_step_1
       segment=acquisition.idx.segment
       #if (counter==1):
       #  lala=np.angle(np.squeeze(acquisition.data[0,:]))
       #  print(np.shape(lala))
       #  plt.plot(lala)
       #  plt.show()
       #  plt.pause(2)

       print(" counter: ", counter, " scan_counter: ", acquisition.scan_counter, " slice: ",slice , " rep: ", repetition, " e1: ", e1," segment: ",  segment)
       connection.send(acquisition)



def EpiPythonGadget(connection):
   counter=0

   # We're only interested in repetition ==0  in this example, so we filter the connection. Anything filtered out in
   # this way will pass back to Gadgetron unchanged.
   connection.filter(lambda acq: acq.idx.slice ==0 and acq.is_flag_set(ismrmrd.ACQ_IS_PHASECORR_DATA) )

   for acquisition in connection:
          
       # DO SOMETHING   
       #print("so far, so good")  
       counter=counter+1;
       #print(counter)
       #print(np.shape(acquisition.data))
       #print(acquisition.active_channels)
       #print(acquisition.scan_counter)
       slice = acquisition.idx.slice
       repetition=  acquisition.idx.repetition
       e1=acquisition.idx.kspace_encode_step_1
       segment=acquisition.idx.segment

       fid=np.abs(np.squeeze(acquisition.data[0,:]))
       print(" counter: ", counter, " scan_counter: ", acquisition.scan_counter, " slice: ",slice , " rep: ", repetition, " e1: ", e1," segment: ",  segment)

       if (acquisition.is_flag_set(ismrmrd.ACQ_IS_REVERSE)):
          plt.plot(fid, 'r')
       else:
          plt.plot(fid, 'b') 
       #if (counter%3==0):  
          #plt.show()
          #plt.pause(2)

       
       connection.send(acquisition)




