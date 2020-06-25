
function GT_reco_nonCart(connection)
tic
disp("handle_connection was called.")

connection.add_reader(uint32(gadgetron.Constants.RECON_DATA), @gadgetron.external.readers.read_recon_data_and_separated_density_weights);

next_acquisition = @connection.next;

acquisition = next_acquisition(); % Call input function to produce the next acquisition.


%% show traj and dcw
figure; 
subplot(2,1,1);plot(acquisition.bits.buffer.trajectory(1,:,1),...
										acquisition.bits.buffer.trajectory(2,:,1));
subplot(2,1,2);plot(acquisition.bits.buffer.density(:,:,1));
%% BART
% see webinard on how to use bart : https://github.com/mrirecon/bart-webinars


%% bart reshape data
trajtmp = acquisition.bits.buffer.trajectory;
% 3D traj : [3,sizeR, proj] (with zero if 2D)
traj = zeros(3,size(trajtmp,2),size(trajtmp,3));
traj(1:2,:,:)=trajtmp;

traj = traj*connection.header.encoding.encodedSpace.matrixSize.x; % scaling 1/FOV unit

% kspace data : [1, sizeR, number of proj, number of channel]
matrice = acquisition.bits.buffer.data;
[sRO, sProj, ~, nCh] = size(matrice);
matrice = reshape(matrice,1,sRO,sProj,nCh);

dcf = repmat(acquisition.bits.buffer.density,[1 1 1 nCh]);
%% create DCF for each channel :
% gridding
agrid = bart('nufft -a', traj,matrice); % blurring due to oversampling
agrid = bart('rss 8',agrid);
figure; subplot(2,2,1);
imshow(agrid,[]); title('Adjoint');

agrid2 = bart('nufft -a ', traj,matrice.*dcf); % if we have dcf we can correct that
agrid2 = bart('rss 8',agrid2);
subplot(2,2,2);imshow(agrid2,[]); title('Adjoint + density');

igrid = bart('nufft -i -c', traj,matrice); % iterative reconstruction 
igrid = bart('rss 8',igrid);
subplot(2,2,3);imshow(igrid,[]); title('Inverse');

% sens with ecalib
igrid2 = bart('nufft -i -c', traj,matrice); % iterative reconstruction 
ksp = bart('fft -u 3', igrid2);
sens = bart('ecalib -m1',ksp);

im_pics = bart('pics -S -e -i200 -R W:3:0:0.001 -t',traj,matrice,sens);
subplot(2,2,4);imshow(abs(im_pics),[]); title('PICS');

% lets try with nlinv
[reco,sens_nlinv] = bart('nlinv -d5 -i10 -t',traj,matrice);
% crop fov by 2 for the sens_nlinv
sens2=bart('crop 0 256',sens_nlinv);
sens2=bart('crop 1 256',sens2);

im_pics2 = bart('pics -S -e -i200 -R W:3:0:0.001 -t',traj,matrice,sens2);

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
