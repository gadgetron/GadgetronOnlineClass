#include <gadgetron/Node.h>
#include <gadgetron/TrajectoryParameters.h>
#include <gadgetron/hoNDArray_utils.h>
#include "SpiralBuffer.h"
using namespace Gadgetron;
using namespace Gadgetron::Core;

class SpiralAccumulateGadget : public ChannelGadget<Core::Acquisition>
{

public:
    SpiralAccumulateGadget(const Core::Context &context, const Core::GadgetProperties &props) : ChannelGadget<Acquisition>(context, props), trajParams(context.header)
    {
    }

    void process(InputChannel<Acquisition> &in, OutputChannel &out) override
    {


        using namespace Gadgetron::Indexing;

        auto [acq_header, data, unused_traj] = in.pop();
        auto [traj, density_compensation] = trajParams.calculate_trajectories_and_weight(acq_header);
        std::vector<hoNDArray<std::complex<float>>> acquisitions{data};
        std::vector<ISMRMRD::AcquisitionHeader> headers{acq_header};

        std::vector<hoNDArray<floatd2>> trajectories{traj(slice,acq_header.idx.kspace_encode_step_1)};
        std::vector<hoNDArray<float>> density_weights{density_compensation(slice,acq_header.idx.kspace_encode_step_1)};

        
        for (auto [acq_header, data, unused_traj] : in)
        {
            acquisitions.emplace_back(std::move(data));
            headers.emplace_back(acq_header);
            trajectories.push_back(traj(slice,acq_header.idx.kspace_encode_step_1));
            density_weights.push_back(density_compensation(slice,acq_header.idx.kspace_encode_step_1));

            if (acq_header.isFlagSet(ISMRMRD::ISMRMRD_ACQ_LAST_IN_SLICE))
            {
                GDEBUG_STREAM("Acquisitions " << acquisitions.size());

                auto combined_acquisitions = concat(acquisitions);
                combined_acquisitions = permute(combined_acquisitions,{0,2,1});
                combined_acquisitions.reshape(-1,combined_acquisitions.get_size(2));

                auto combined_density = concat(density_weights);
                combined_density.reshape(-1);
                auto combined_traj = concat(trajectories);
                combined_traj.reshape(-1);


                out.push(SpiralBuffer{std::move(combined_acquisitions), std::move(combined_traj), std::move(combined_density), std::move(headers)});
                acquisitions.clear();
                headers.clear();
                trajectories.clear();
                density_weights.clear();
            }
        }
    }

private:
    Spiral::TrajectoryParameters trajParams;
};


GADGETRON_GADGET_EXPORT(SpiralAccumulateGadget)