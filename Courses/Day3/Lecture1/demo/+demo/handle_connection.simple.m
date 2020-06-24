
function handle_connection(connection)
    while true
        recon_data = connection.next();

        data = recon_data.bits.buffer.data;

        image = gadgetron.lib.fft.cifftn(data, [1 2 3]);
        image = combine_channels(image);

        image = gadgetron.types.Image.from_data(...
            permute(image, [4 1 2 3]), ...
            reference_from_recon_data(recon_data) ...
        ); 

        disp("Sending image to Client.");

        connection.send(image);
    end
end

function image = combine_channels(image)
    square = @(x) x .^ 2;
    image = sqrt(sum(square(abs(image)), 4));
end

function reference = reference_from_recon_data(recon_data)
    reference = structfun(@(field) field(:, end), recon_data.bits.buffer.headers, 'UniformOutput', false);
end
