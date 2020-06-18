function [ kspace_corr] = EPI_trapezoid_regridding(parameters,kspace)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here


reconx.numSamples_=parameters.readout;
reconx.rampUpTime_=parameters.rampUpTime;
reconx.rampDownTime_=parameters.rampDownTime;
reconx.acqDelayTime_=parameters.acqDelayTime;
reconx.flatTopTime_=parameters.flatTopTime;
reconx.dwellTime_=parameters.dwellTime;
reconx.encodeNx_ = parameters.N_phase_encode;
reconx.encodeFOV_ = parameters.FOV_1;
reconx.reconNx_ = parameters.N_phase_recon;

% Initialize the k-space trajectory arrays
trajectoryPos=zeros(reconx.numSamples_,1);
trajectoryNeg=zeros(reconx.numSamples_,1);

%  Temporary trajectory for a symmetric readout
%  first calculate the integral with G = 1;
nK = reconx.numSamples_;
k=zeros(nK,1);
%   float t;

%    Some timings
totTime = reconx.rampUpTime_ + reconx.flatTopTime_ + reconx.rampDownTime_;
readTime = reconx.dwellTime_ * reconx.numSamples_;

balanced_=1;
% Fix the acqDelayTime for balanced acquisitions
if (balanced_==1)
    reconx.acqDelayTime_ = 0.5 * (totTime - readTime);
end

% Some Areas
totArea = 0.5*reconx.rampUpTime_ + reconx.flatTopTime_ + 0.5*reconx.rampDownTime_;
readArea =  0.5*reconx.rampUpTime_ + reconx.flatTopTime_ + 0.5*reconx.rampDownTime_;

if (reconx.rampUpTime_ > 0.0)
    readArea =  readArea - 0.5*(reconx.acqDelayTime_)*(reconx.acqDelayTime_)/reconx.rampUpTime_;
end
if (reconx.rampDownTime_ > 0.0)
    readArea = readArea - 0.5*(totTime - (reconx.acqDelayTime_+readTime))*(totTime - (reconx.acqDelayTime_+readTime))/reconx.rampDownTime_;
end

% Prephase is set so that k=0 is halfway through the readout time
prePhaseArea = 0.5 * totArea;

% The scale is set so that the read out area corresponds to the number of encoded points
scale = reconx.encodeNx_ /readArea;

for n=1:1:nK
    
    t = ((n-1)+1.0)*reconx.dwellTime_ + reconx.acqDelayTime_;  % end of the dwell time
    if (t <= reconx.rampUpTime_)
        % on the ramp up
        k(n,1) = 0.5 / reconx.rampUpTime_ * t*t;
        
    elseif ((t > reconx.rampUpTime_) && (t <= (reconx.rampUpTime_+reconx.flatTopTime_)))
        % on the flat top
        k(n,1) = 0.5*reconx.rampUpTime_ + (t - reconx.rampUpTime_);
    else
        % on the ramp down
        v = (reconx.rampUpTime_+reconx.flatTopTime_+reconx.rampDownTime_-t);
        k(n,1) = 0.5*reconx.rampUpTime_ + reconx.flatTopTime_ + 0.5*reconx.rampDownTime_ - 0.5/reconx.rampDownTime_*v*v;
    end
%     str_msg=sprintf('%d %f %f \n', n, t , k(n,1)); disp(str_msg);
end


%   // Fill the positive and negative trajectories
for n=1:1:reconx.numSamples_
    
    trajectoryPos_(n,1) = scale * (k(n,1) - prePhaseArea);
    trajectoryNeg_(n,1) = scale * (-1.0*k(n,1) + totArea - prePhaseArea);
%     str_msg=sprintf('%d %f %f \n', n,trajectoryPos_(n,1) , trajectoryNeg_(n,1)); disp(str_msg);
end


% Compute the reconstruction operator
Km = floor(reconx.encodeNx_ / 2.0);
Ne = 2*Km + 1;

% resize the reconstruction operator
Mpos_=zeros(reconx.reconNx_,reconx.numSamples_);
Mneg_=zeros(reconx.reconNx_,reconx.numSamples_);

% evenly spaced k-space locations
keven = linspace(-Km, Km, Ne);
%keven.print("keven =");

% image domain locations [-0.5,...,0.5)
x = linspace(-0.5,(reconx.reconNx_-1.)/(2.*reconx.reconNx_),reconx.reconNx_);
%x.print("x =");

% DFT operator
% Going from k space to image space, we use the IFFT sign convention
F=zeros(reconx.reconNx_, Ne);
fftscale = 1.0 / sqrt(Ne);

for p=1:1:reconx.reconNx_
    for q=1:1:Ne
        F(p,q) = fftscale * exp(complex(0.0,1.0*2*pi*keven(q)*x(p)));
    end
end
%F.print("F =");

% forward operators
Qp=zeros(reconx.numSamples_, Ne);
Qn=zeros(reconx.numSamples_, Ne);

for p=1:1:reconx.numSamples_
    %GDEBUG_STREAM(trajectoryPos_(p) << "    " << trajectoryNeg_(p) << std::endl);
    for q=1:1:Ne
        Qp(p,q) = sinc(trajectoryPos_(p)-keven(q));
        Qn(p,q) = sinc(trajectoryNeg_(p)-keven(q));
    end
end

%Qp.print("Qp =");
%Qn.print("Qn =");

% recon operators
Mp=zeros(reconx.reconNx_,reconx.numSamples_);
Mn=zeros(reconx.reconNx_,reconx.numSamples_);
Mp = F * pinv(Qp);
Mn = F * pinv(Qn);

% Compute the off-center correction:     /////

% Compute the off-center distance in the RO direction:
roOffCenterDistance = calcOffCenterDistance( parameters );
%GDEBUG_STREAM("roOffCenterDistance_: " << roOffCenterDistance << ";       encodeFOV_: " << encodeFOV_);

my_keven = linspace(0, reconx.numSamples_ -1, reconx.numSamples_);
%         % find the offset:
%         % PV: maybe find not just exactly 0, but a very small number?
trajectoryPosArma = trajectoryPos_;

n = find( trajectoryPosArma==0, 1, 'first');

my_keven = my_keven - (n-1);  %%attention 128

% my_keven
%         % Scale it:
%         % We have to find the maximum k-trajectory (absolute) increment:
Delta_k = abs( trajectoryPosArma(2:reconx.numSamples_,1) - trajectoryPosArma(1:reconx.numSamples_-1,1));
% max(Delta_k(:))

my_keven = my_keven *max(Delta_k(:));
%
%         % off-center corrections:


clear offCenterCorrN offCenterCorrP

myExponent = zeros(reconx.numSamples_,1);


for l=1:size(trajectoryPosArma,1)
    myExponent(l,1)=imag( 2*pi*roOffCenterDistance/reconx.encodeFOV_*(trajectoryPosArma(l,1)-my_keven(1,l)) );
end

offCenterCorrN = exp( myExponent );

for l=1:size(trajectoryPosArma,1)
    myExponent(l,1)=imag( 2*pi*roOffCenterDistance/reconx.encodeFOV_*(trajectoryNeg_(l,1)+my_keven(1,l)) );
end

offCenterCorrP = exp( myExponent );


%         %    for (q=0; q<numSamples_; q++) {
%         %      GDEBUG_STREAM("keven(" << q << "): " << my_keven(q) << ";       trajectoryPosArma(" << q << "): " << trajectoryPosArma(q) );
%         %      GDEBUG_STREAM("offCenterCorrP(" << q << "):" << offCenterCorrP(q) );
%         %    }


%         Finally, combine the off-center correction with the recon operator:
Mp = Mp * diag(offCenterCorrP);
Mn = Mn * diag(offCenterCorrN);

%          and save it into the NDArray members:
for p=1:1:reconx.reconNx_
    for q=1:1:reconx.numSamples_
        Mpos_(p,q) = Mp(p,q);
        Mneg_(p,q) = Mn(p,q);
    end
end

% size(Mpos_)
% size(Mneg_)
%Mp.print("Mp =");
%Mn.print("Mn =");

mat_is_reverse = reshape(parameters.is_reversed_acq,parameters.N_phase_encode(1,1),parameters.N_slices(1,1));
kspace_corr = zeros(size(kspace,1)/2,size(kspace,2),size(kspace,3),size(kspace,4));

for dim2 = 1:size(kspace,2)
    for dim4 = 1:size(kspace,4)
        if mat_is_reverse(dim2,dim4)==1
           kspace_corr(:,dim2,:,dim4) = Mneg_*squeeze(kspace(:,dim2,:,dim4));
        else
            kspace_corr(:,dim2,:,dim4) = Mpos_*squeeze(kspace(:,dim2,:,dim4));
        end       
    end
end

return


function roOffCenterDistance=calcOffCenterDistance( parameters)

% armadillo vectors with the position and readout direction:
pos=zeros(3,1);
RO_dir=zeros(3,1);

for i=1:1:3
    pos(i,1)    = parameters.position(i);
    RO_dir(i,1) = parameters.read_dir(i);
end

roOffCenterDistance = dot(pos, RO_dir);
%GDEBUG_STREAM("roOffCenterDistance: " << roOffCenterDistance );

return
