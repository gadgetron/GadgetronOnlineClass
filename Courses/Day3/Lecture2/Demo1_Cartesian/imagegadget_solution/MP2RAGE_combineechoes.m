function next = MP2RAGE_combineechoes(connection)

    connection.filter('gadgetron.types.Image')
    images = gadgetron.types.Image.empty();
    counter=0;

    function allimg = accumulate()
            
        while true
            fprintf('Receiving image %d ',counter);
            counter = counter+1;
            images(counter) = connection.next();
            connection.send(images(counter));
            
            if counter==2
                protocolname =  connection.header.measurementInformation.protocolName; % string
                fprintf('\n Last img from %s \n',protocolname);
                
                MP2RAGE = gadgetron.custom.functions.MP2RAGE_combineEchos(images(1).data,images(2).data);
                %make it complex for the Extract gadget
                images(1).data=MP2RAGE+1i*eps; 
                % increment series number
                images(1).header.image_series_index=images(1).header.image_series_index+1;
                connection.send(images(1));
                break; 
            end
        end
        
        allimg=images;
    end
    
    tic, gadgetron.consume(@accumulate); toc
    
end