
function MP2RAGE_bufferrecon(connection)

    disp("Matlab reconstruction running.");
    
    next = gadgetron.examples.steps.create_slice_from_recon_data(@connection.next);        
    next = gadgetron.examples.steps.basic_reconstruction(next);
    next = gadgetron.custom.steps.combine_channels_cplx(next);
    
    %output complex data
    next = gadgetron.custom.steps.create_ismrmrd_image_cplx(next);
    next = gadgetron.custom.steps.send_image_to_client(next, connection);
    
    %compute and output MP2RAGE
    next = gadgetron.custom.functions.MP2RAGE_combineEchoes(next,connection.header);
    next = gadgetron.custom.steps.send_image_to_client(next, connection);
    
    tic, gadgetron.consume(next); toc
end
