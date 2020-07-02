#include <gadgetron/Node.h>
#include "SpiralBuffer.h"
#include <gadgetron/hoNFFT.h>
#include <gadgetron/mri_core_coil_map_estimation.h>
#include <gadgetron/mri_core_utility.h>
#include <gadgetron/hoNDArray_utils.h>
#include <gadgetron/hoCgSolver.h>
#include <gadgetron/hoNDImage_util.h>
#include "NonCartesianSenseOperator.h"

using namespace Gadgetron;
using namespace Gadgetron::Core;
using namespace Tutorial;

static auto create_CSM(const hoNDArray<std::complex<float>> &data, const hoNDArray<float> &dcw, const hoNDArray<floatd2> &trajectory, ISMRMRD::MatrixSize &matrix_size)
{
    auto nfft_plan = hoNFFT_plan<float, 2>(vector_td<size_t, 2>{matrix_size.x, matrix_size.y}, 1.5f, 5.5f);
    nfft_plan.preprocess(trajectory);

    hoNDArray<std::complex<float>> image(matrix_size.x, matrix_size.y, data.get_size(1));

    nfft_plan.compute(data, image, &dcw, NFFT_comp_mode::BACKWARDS_NC2C);

    image.reshape(matrix_size.x, matrix_size.y, 1, image.get_size(2));

    return coil_map_Inati(image);
}

class NonCartesianSENSE : public ChannelGadget<SpiralBuffer>
{

public:
    using ChannelGadget<SpiralBuffer>::ChannelGadget;

    void process(InputChannel<SpiralBuffer> &in, OutputChannel &out)
    {
        auto matrix_size = this->header.encoding.front().reconSpace.matrixSize;

        for (auto [data, trajectory, dcw, headers] : in)
        {

            auto csm = create_CSM(data,dcw,trajectory, matrix_size);
            sqrt_inplace(&dcw);
            data *= dcw;

            auto image_dimensions = std::vector<size_t>{matrix_size.x,matrix_size.y,1};

            auto sense_op = boost::make_shared<NonCartesianSenseOperator<2>>(image_dimensions, data.dimensions(), std::move(csm),std::move(dcw), trajectory);


            hoCgSolver<std::complex<float>> solver;
            solver.set_encoding_operator(sense_op);
            
            auto image = solver.solve(&data);

            auto header = image_header_from_acquisition(headers.front(), this->header, *image);
            GDEBUG("PUSHING IMAGE\n");
            out.push(header, std::move(*image));
        }
    }
};

GADGETRON_GADGET_EXPORT(NonCartesianSENSE)