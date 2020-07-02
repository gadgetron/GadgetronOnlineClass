#include <gadgetron/Node.h>
#include "SpiralBuffer.h"
#include <gadgetron/hoNFFT.h>
#include <gadgetron/mri_core_coil_map_estimation.h>
#include <gadgetron/mri_core_utility.h>
#include <gadgetron/hoNDArray_utils.h>

using namespace Gadgetron;
using namespace Gadgetron::Core;
class NonCartesianGridding : public ChannelGadget<SpiralBuffer> {

    public:

        using ChannelGadget<SpiralBuffer>::ChannelGadget;

        void process(InputChannel<SpiralBuffer>& in, OutputChannel& out){
            auto matrix_size = this->header.encoding.front().reconSpace.matrixSize;

            for (auto [data,trajectory,dcw, headers] : in ){
            
            auto nfft_plan = hoNFFT_plan<float, 2>(vector_td<size_t,2>{matrix_size.x,matrix_size.y},1.5f,5.5f);
            nfft_plan.preprocess(trajectory);

            hoNDArray<std::complex<float>> image(matrix_size.x,matrix_size.y,data.get_size(1));

            nfft_plan.compute(data,image,&dcw,NFFT_comp_mode::BACKWARDS_NC2C);

            image.reshape(matrix_size.x,matrix_size.y,1,image.get_size(2));

            auto csm = coil_map_Inati(image);
            image = coil_combine(image,csm,3);

            auto header = image_header_from_acquisition(headers.front(),this->header,image);
            GDEBUG("PUSHING IMAGE\n");
            out.push(header,std::move(image));

            }
        }

};

GADGETRON_GADGET_EXPORT(NonCartesianGridding)