#include <gadgetron/Node.h>
#include "AcquisitionBuffer.h"
#include <gadgetron/hoNDFFT.h> 

#include <gadgetron/mri_core_coil_map_estimation.h>
#include <gadgetron/mri_core_utility.h>


using namespace Gadgetron;
using namespace Gadgetron::Core;

class FFTRecon : public ChannelGadget<AcquisitionBuffer> {

    public:
        using ChannelGadget<AcquisitionBuffer>::ChannelGadget;

        void process(InputChannel<AcquisitionBuffer>& in, OutputChannel& out){
            
            for (auto buffer : in) {
                GDEBUG("BUFFER\n");

                auto data = FFT::ifft3c(buffer.data);
                auto coil_map = coil_map_Inati(data);
                data = coil_combine(data,coil_map, 3);

                auto image_header =  image_header_from_acquisition(buffer.headers.front(),this->header,data);

                out.push(image_header,data);

            }
        }
};


GADGETRON_GADGET_EXPORT(FFTRecon)