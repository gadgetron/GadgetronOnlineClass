
function handle_connection(connection)

    input = @connection.next;
    input = @() buffer_from_recon_data(input());
    input = @() reconstruct_buffer(input());
    input = @() create_image_from_buffer(input());
    input = @() send_image_to_client(input(), connection);
    
    tic, gadgetron.consume(input); toc
end


function buffer = buffer_from_recon_data(recon_data)
    buffer.data = recon_data.bits.buffer.data;
    buffer.reference = reference_from_recon_data(recon_data);
end

function buffer = reconstruct_buffer(buffer)
    buffer.data = gadgetron.lib.fft.cifftn(buffer.data, [1 2 3]);
    buffer.data = combine_channels(buffer.data);
end

function image = create_image_from_buffer(buffer)
    image = gadgetron.types.Image.from_data(...
        permute(buffer.data, [4 1 2 3]), ...
        buffer.reference ...
    ); 
end

function send_image_to_client(image, connection)
    disp("Sending image to client.");
    connection.send(image);
end

function image = combine_channels(image)
    square = @(x) x .* conj(x);
    image = sqrt(sum(square(image), 4));
end

function reference = reference_from_recon_data(recon_data)
    reference = structfun(@(field) field(:, end), recon_data.bits.buffer.headers, 'UniformOutput', false);
end
