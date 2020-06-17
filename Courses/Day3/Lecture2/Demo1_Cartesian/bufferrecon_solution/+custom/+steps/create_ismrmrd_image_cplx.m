function next = create_ismrmrd_image_cplx(input)
    n=1;
    s=1;
        function imageout = create_image(image)
            %init
            imageout(1,1)=gadgetron.types.Image.from_data(zeros(128),ismrmrd.ImageHeader());
            for n=1:size(image.reference,1)
                for s=1:size(image.reference,2)
                    imageout(2*n-1,s) = gadgetron.types.Image.from_data(abs(image.data(:,:,:,:,n,s)), image.reference(n,s));
                    imageout(2*n-1,s).header.image_series_index=1;
                    imageout(2*n-1,s).header.image_type = gadgetron.types.Image.MAGNITUDE;
                    
                    imageout(2*n,s) = gadgetron.types.Image.from_data(angle(image.data(:,:,:,:,n,s)), image.reference(n,s));
                    imageout(2*n-1,s).header.image_series_index=2;
                    imageout(2*n,s).header.image_type = gadgetron.types.Image.PHASE;
                end
            end
        end

    next = @() create_image(input());
end
