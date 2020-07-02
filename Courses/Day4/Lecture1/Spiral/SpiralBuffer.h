#pragma once
#include <gadgetron/hoNDArray.h>
#include <ismrmrd/ismrmrd.h>

namespace Gadgetron {
    struct SpiralBuffer { 
        hoNDArray<std::complex<float>> data;
        hoNDArray<vector_td<float,2>> trajectory;
        hoNDArray<float> dcw;
        std::vector<ISMRMRD::AcquisitionHeader> headers;
    };
}