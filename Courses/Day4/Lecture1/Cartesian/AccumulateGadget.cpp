#include <gadgetron/Node.h>
#include "AcquisitionBuffer.h"

using namespace Gadgetron;

class AccumulateGadget : public Core::ChannelGadget<Core::Acquisition>
{
public:
    using Core::ChannelGadget<Core::Acquisition>::ChannelGadget;

    void process(Core::InputChannel<Core::Acquisition> &input, Core::OutputChannel &output) override
    {
        auto matrix_size = this->header.encoding.front().reconSpace.matrixSize;
        const auto data_size = std::vector<size_t>{matrix_size.x, matrix_size.y, matrix_size.z, this->header.acquisitionSystemInformation->receiverChannels.get()};
        hoNDArray<std::complex<float>> kspace(data_size);

        std::vector<ISMRMRD::AcquisitionHeader> headers;

        for (const auto [acq_header, data, trajectory] : input)
        {
            using namespace Gadgetron::Indexing;

            //kspace(:,acq_header.idx.kspace_encode_step_1,acq_header.idx.kspace_encode_step_2,:) = data;
            kspace(slice, acq_header.idx.kspace_encode_step_1, acq_header.idx.kspace_encode_step_2, slice) = data;

            headers.push_back(acq_header);
            GDEBUG("Acquisition!\n");
            if (acq_header.isFlagSet(ISMRMRD::ISMRMRD_ACQ_LAST_IN_SLICE))
            {
                GDEBUG("Sending out data\n");
                output.push(AcquisitionBuffer{std::move(kspace), std::move(headers)});

                headers = std::vector<ISMRMRD::AcquisitionHeader>{};
                kspace = hoNDArray<std::complex<float>>(data_size);
            }
        }
    }
};

GADGETRON_GADGET_EXPORT(AccumulateGadget)