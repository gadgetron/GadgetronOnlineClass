function next = passthrough_header(connection)

    acquisitions = gadgetron.types.Acquisition.empty();
    counter=0;

    protocolname =  connection.header.measurementInformation.protocolName; % string
    fprintf('\n Started processing %s \n',protocolname);
    
    function totacq = accumulate()
            
        while true
            fprintf('%d ',counter);
            counter = counter+1;
            acquisitions(counter) = connection.next();
            connection.send(acquisitions(counter));
            
            if acquisitions(counter).is_flag_set(acquisitions(counter).ACQ_LAST_IN_MEASUREMENT)
                break; 
            end
        end
        
        totacq=acquisitions;
    end
    
    tic, gadgetron.consume(@accumulate); toc
    
end