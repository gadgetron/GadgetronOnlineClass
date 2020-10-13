
function GT_reco_traj(connection)
SHOW_RECO_BART = 0; % if you want to show the reconstruction with bart (to compare)

disp("handle_connection was called.")

%% create traj
sRO = connection.header.encoding.encodedSpace.matrixSize.x * 2; % x2 because ROoversampling is not removed for non-cartesian acquistion
NPro = connection.header.encoding.encodingLimits.kspace_encoding_step_1.maximum + 1;

traj=compute_traj4bart(sRO, NPro, 0); % correspond to the uniform increment (360/NPro)
%% Read acquisition -> fill the traj -> send back
next_acquisition = @connection.next;

try
    while true
        acquisition = next_acquisition();
        acquisition.trajectory = single(traj(1:2,:,acquisition.header.scan_counter)); %2D acquisition without DCF
        acquisition.header.trajectory_dimensions = 2;

        connection.send(acquisition);
        
        % buffer the acquisition for bart
        matrice(:,:,acquisition.header.scan_counter)=acquisition.data;
        
    end
catch 
    disp('error');
end

%% Kristoffer way to wrote gadget
%     next_acquisition = @connection.next;
%     acq_traj = @() add_traj(next_acquisition,traj);
%     send_acq = @() connection.send(acq_traj());
% 
%     tic; gadgetron.consume(send_acq); toc  

if SHOW_RECO_BART
    %% Do the bart reco to check
    sRO = size(matrice,1);
    nCh = size(matrice,2);

    matrice2=permute(matrice,[1 3 2]);
    matrice2=reshape(matrice2,1,sRO,[],nCh);
    %% reco : 

    igrid = bart('nufft -i', traj*sRO/2,matrice2); % iterative reconstruction 
    igrid = bart('rss 8',igrid);
    imshow(igrid,[]); title('Inverse');
end
end

%% suppport functions
function acquisition = add_traj(input,traj)
    acquisition = input();
    acquisition.trajectory = traj(1:2,acquisition.header.scan_counter); %2D acquisition without DCF
end


function K=compute_traj4bart(ADCres, Nspokes, SamplingType,TrajOffset)

% generate a radial trajectory with Nspokes lines.
% kloc_onesided=getpolar(Nspokes,ADCres);
% kloc_centered=kloc_onesided-ADCres/2-ADCres/2*1i-1-1i;

switch SamplingType
    case 0 % regular full spoke
        angleIncrement = pi / Nspokes;
    case 1 % golden angle full spoke
        angleIncrement = pi * (sqrt(5)-1)/2;
    case 2 % golden angle small version full spoke
        angleIncrement = pi * (3-sqrt(5))/2; 
    case 3 % regular half spoke
        angleIncrement = 2*pi / Nspokes;
    case 4 % golden angle half spoke
        angleIncrement = 2*pi * (sqrt(5)-1)/2;
    case 5% golden angle small version half spoke
        angleIncrement = 2*pi * (3-sqrt(5))/2; 
end

% between -.5 and .5
if(SamplingType<3)
   SpokeVector = linspace(-ADCres/2+1,ADCres/2,ADCres);
else
   SpokeVector = linspace(0,ADCres,ADCres);
end
SpokeVector = SpokeVector/ADCres;

% Compute the exact Fourier samples on the radial trajectory.

if(~exist('TrajOffset','var'))
    TrajOffset=0;
end

K = zeros([3,ADCres,Nspokes]);

 for s = 1:Nspokes
    cs = TrajOffset + s-1;
    K(1,:,s) = SpokeVector*cos(cs*angleIncrement);
    K(2,:,s) = SpokeVector*sin(cs*angleIncrement);

 end
end
