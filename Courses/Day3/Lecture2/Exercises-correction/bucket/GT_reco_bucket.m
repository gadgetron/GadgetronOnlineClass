
function GT_reco_bucket(connection)

next_acquisition = @connection.next;

acquisition = next_acquisition(); % Call input function to produce the next acquisition.

sRO = connection.header.encoding.reconSpace.matrixSize.x;
sPE = connection.header.encoding.reconSpace.matrixSize.y;
sSE = connection.header.encoding.reconSpace.matrixSize.z;
nContrast = connection.header.encoding.encodingLimits.contrast.maximum;
maxDim = nContrast + 1;
nCh = size(acquisition.data.data,2);

kdata=zeros(sRO,nCh,sPE*sSE,maxDim); % initialize matrixwith zero

% find indices of each kspace line
row = acquisition.data.header.kspace_encode_step_1 + 1;
col = acquisition.data.header.kspace_encode_step_2 + 1;
TI_idx = acquisition.data.header.contrast + 1;

% buffer the data at the right place into kdata (faster than using
% bucket_to_buffer because of the sparse matrix)
kdata(:,:,sub2ind([sPE,sSE,maxDim],row,col,TI_idx))=acquisition.data.data;
kdata = permute(kdata,[1 3 2 4]);
kdata=reshape(kdata,sRO,sPE,sSE,nCh,1,[]); %% buffering the echo according to bart convetion [RO,E1,E2,CHA,MAP,CON]

% Repeat this for reference data (if exist)
if(acquisition.reference.count > 0)
    % ref is deprecated you should use reference instead
    kref=zeros(sRO,nCh,sPE*sSE,maxDim);
    row = acquisition.reference.header.kspace_encode_step_1 + 1;
    col = acquisition.reference.header.kspace_encode_step_2 + 1;
    
    TI_idx = acquisition.reference.header.contrast + 1;
    
    kref(:,:,sub2ind([sPE,sSE,maxDim],row,col,TI_idx))=acquisition.reference.data;
    kref = permute(kref,[1 3 2 4]);
    kref=reshape(kref,sRO,sPE,sSE,nCh,1,[]); %% buffering the echo according to bart convetion [RO,E1,E2,CHA,MAP,CON]
end

%% simple fft
im_fft = fftshift(ifft2(ifftshift(kdata)));

%% combine channnel
im_fft = sqrt(sum(abs(im_fft).^2,4));
figure;imshow(im_fft(:,:,2),[]);
%% Permute data : channel, readout, PE, SE
img_to_send=permute(abs(im_fft),[6, 1, 2, 3, 4 ,5]);

%% send image

image = gadgetron.types.Image.from_data(img_to_send, reference_header(acquisition));
image.header.image_type = gadgetron.types.Image.MAGNITUDE;

disp("Sending image to client.");
connection.send(image);
end

%% suppport functions
function reference = reference_header(bucket_data)
    % We pick the first header from the header arrays - we need it to initialize the image meta data.    
    reference = structfun(@(arr) arr(:, 1)', bucket_data.data.header, 'UniformOutput', false);
end
