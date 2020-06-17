function next = MP2RAGE_combineEchoes(input,header)
    multiFactor=1;
    n=1;
    s=1;
    function imageout = combine_echoes(image)
        imageout=image(1,1);
        %recombine complex data for processing
        for s=1:size(image,2)
            for n=1:size(image,1)/2    
                    image(n,s).data = (image(2*n-1,s).data).*exp(1i*image(2*n,s).data);
            end
            multiFactor=mean(abs(image(2,s).data(:)));
            imageout(1,s).data=real((conj(image(1,s).data).*image(2,s).data-multiFactor)./(abs(image(1,s).data).^2+abs(image(2,s).data).^2+2*multiFactor));
        end
        % update series index 
        imageout(1,s).header.image_series_index=3;
       
    end

    next = @() combine_echoes(input());
end