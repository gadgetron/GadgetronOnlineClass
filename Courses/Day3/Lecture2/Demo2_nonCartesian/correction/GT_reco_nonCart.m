
function GT_reco_nonCart(connection)
tic
disp("handle_connection was called.")

connection.add_reader(uint32(gadgetron.Constants.RECON_DATA), @gadgetron.external.readers.read_recon_data_and_separated_density_weights);

next_acquisition = @connection.next;

acquisition = next_acquisition(); % Call input function to produce the next acquisition.

%% BART
% see webinard on how to use bart : https://github.com/mrirecon/bart-webinars


%% bart reshape data
trajtmp = acquisition.bits.buffer.trajectory;
% 3D traj : [3,sizeR, proj] (with zero if 2D)
traj = zeros(3,size(trajtmp,2),size(trajtmp,3));
traj(1:2,:,:)=trajtmp;
traj = traj*connection.header.encoding.encodedSpace.fieldOfView_mm.x; % scalinng 1/FOV unit

% kspace data : [1, sizeR, number of proj, number of channel]
matrice = acquisition.bits.buffer.data;
[sRO, sProj, ~, nCh] = size(matrice);
matrice = reshape(matrice,1,sRO,sProj,nCh);

dcf = repmat(acquisition.bits.buffer.density,[1 1 1 nCh]);
%% create DCF for each channel :
% gridding
agrid = bart('nufft -a', traj,matrice); % blurring due to oversampling
agrid = bart('rss 8',agrid);
figure; imshow(agrid,[]); title('Adjoint');

agrid = bart('nufft -a ', traj,matrice.*dcf); % if we have dcf we can correct that
agrid = bart('rss 8',agrid);
figure; imshow(agrid,[]); title('Adjoint + density');

igrid = bart('nufft -i -c', traj,matrice); % iterative reconstruction 
igrid = bart('rss 8',igrid);
figure; imshow(igrid,[]); title('Inverse');

% sens with ecalib
igrid2 = bart('nufft -i -c', traj,matrice); % iterative reconstruction 
ksp = bart('fft -u 3', igrid2);
sens = bart('ecalib -m1',ksp);

im_pics = bart('pics -S -e -i200 -R W:3:0:0.01 -t',traj,matrice,sens);

% lets try with nlinv
[reco,sens_nlinv] = bart('nlinv -d5 -i10 -t',traj,matrice);
% crop fov by 2 for the sens_nlinv
sens2=bart('crop 0 320',sens_nlinv);
sens2=bart('crop 1 320',sens2);

im_pics2 = bart('pics -S -e -i200 -R W:3:0:0.01 -t',traj,matrice,sens2);

%% Permute data : channel, readout, PE, SE
img_to_send{1}=permute(abs(reco),[4, 1, 2, 3]);
img_to_send{2}=permute(abs(im_pics),[4, 1, 2, 3]);
%% send image

for ii=1:length(img_to_send)
    image = gadgetron.types.Image.from_data(img_to_send{ii}, reference_header(acquisition));
    image.header.image_type = gadgetron.types.Image.MAGNITUDE;
    
    disp("Sending image to client.");
    connection.send(image);
end
toc
end

%% suppport functions
function reference = reference_header(recon_data)
    % We pick the first header from the header arrays - we need it to initialize the image meta data.    
    reference = structfun(@(arr) arr(:, 1)', recon_data.bits.buffer.headers, 'UniformOutput', false);
end
