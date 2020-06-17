function next = send_image_to_client(input, connection)
    n=1;
    s=1;
    function image = send_image(image)
        for n=1:size(image,1)
            for s=1:size(image,2)
  fprintf("Sending image %d/%d %d/%d to client.\n",n,size(image,1),s,size(image,2));
  connection.send(image(n,s));
            end
        end
    end

    next = @() send_image(input());
end
