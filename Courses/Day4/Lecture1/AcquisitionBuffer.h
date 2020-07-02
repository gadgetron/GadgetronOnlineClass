#pragma once
#include <gadgetron/hoNDArray.h>
#include <ismrmrd/ismrmrd.h>

struct AcquisitionBuffer {
    Gadgetron::hoNDArray<std::complex<float>> data;
    std::vector<ISMRMRD::AcquisitionHeader> headers;

};