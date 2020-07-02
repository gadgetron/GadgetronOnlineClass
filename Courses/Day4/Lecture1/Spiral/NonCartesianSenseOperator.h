#pragma once

#include <gadgetron/linearOperator.h>
#include <gadgetron/hoNDArray.h>
#include <gadgetron/hoNDArray_math.h>
#include <gadgetron/hoNDFFT.h>

namespace Tutorial
{
    using namespace Gadgetron;

    template <unsigned int D>
    class NonCartesianSenseOperator : public linearOperator<hoNDArray<std::complex<float>>>
    {
    public:
        NonCartesianSenseOperator(const std::vector<size_t> &image_dimensions, const std::vector<size_t> &kspace_dimensions, hoNDArray<std::complex<float>> csm, hoNDArray<float> dcw,
                                   const hoNDArray<vector_td<float,D>>& traj) :
                                    csm{std::move(csm)}, dcw{std::move(dcw)},
                                    nfft_plan(from_std_vector<size_t,2>(image_dimensions), 1.5f, 5.5f)
        {
            this->set_domain_dimensions(&image_dimensions);
            this->set_codomain_dimensions(&kspace_dimensions);
            nfft_plan.preprocess(traj);
        }

        void mult_M(hoNDArray<std::complex<float>> *in_ptr, hoNDArray<std::complex<float>> *out_ptr, bool accumulate) override
        {
            const auto &in = *in_ptr;
            auto &out = *out_ptr;

            auto tmp_array = hoNDArray<std::complex<float>>(csm.dimensions());

            int channels = csm.get_size(3);

            for (int c = 0; c < channels; c++)
            {
                using namespace Gadgetron::Indexing;
                tmp_array(slice, slice, slice, c) = in;
            }
            tmp_array *= csm;

            if (accumulate){
                hoNDArray<std::complex<float>> tmp_out(out.dimensions());
                nfft_plan.compute(tmp_array,tmp_out, &dcw, NFFT_comp_mode::FORWARDS_C2NC);
                out += tmp_out;
            } else {
                nfft_plan.compute(tmp_array,out, &dcw, NFFT_comp_mode::FORWARDS_C2NC);
            }

        }

        void mult_MH(hoNDArray<std::complex<float>> *in_ptr, hoNDArray<std::complex<float>> *out_ptr, bool accumulate) override
        {
            const auto &in = *in_ptr;
            auto &out = *out_ptr;

            auto tmp_array = hoNDArray<std::complex<float>>(csm.dimensions());
            nfft_plan.compute(in,tmp_array, &dcw, NFFT_comp_mode::BACKWARDS_NC2C);
            if (!accumulate)
                out.fill(0);

            multiplyConj(tmp_array, csm, tmp_array);
            if (accumulate){
                auto tmp_out = out;
                sum_over_dimension(tmp_array, tmp_out, 3);
                out += tmp_out;
            } else {
                sum_over_dimension(tmp_array, out, 3);
            }
        }

    private:
        const hoNDArray<std::complex<float>> csm;
        const hoNDArray<float> dcw;
        hoNFFT_plan<float, D> nfft_plan;
    };
} // namespace Tutorial