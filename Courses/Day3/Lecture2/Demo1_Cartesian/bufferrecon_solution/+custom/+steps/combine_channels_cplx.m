function next = combine_channels_cplx(input)
    labs=1;
    lphase=1;
    function x = square(x), x = x .^ 2; end
    function image = combine_channels_cplx(image)
            labs = sqrt(sum(square(abs(image.data)), 1));
            lphase = sum(angle(image.data).*abs(image.data),1)./labs;
        image.data=(labs).*exp(1i*lphase);
    end

    next = @() combine_channels_cplx(input());
end

