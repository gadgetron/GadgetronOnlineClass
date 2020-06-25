function next = create_slice_from_recon_data(input)
    %loop index over buffer N and S dimensions
    n=1;
    s=1;
    function slice = create_slice(recon_data)
        for n=1:size(recon_data.bits.buffer.headers.center_sample,4)
            for s=1:size(recon_data.bits.buffer.headers.center_sample,5)
                slice.reference(n,s) = structfun(@(arr) arr(:, 1,1,n,s)', recon_data.bits.buffer.headers, 'UniformOutput', false);
            end
        end
        slice.data = permute( ...
            recon_data.bits.buffer.data, ...
            [4, 1, 2, 3, 5, 6] ... 
            );
        %fprintf("Size of data is %d %d %d %d %d\n",size(slice.data));
    end

    next = @() create_slice(input());
end

