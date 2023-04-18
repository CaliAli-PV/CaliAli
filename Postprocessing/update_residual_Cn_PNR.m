function neuron=update_residual_Cn_PNR(neuron)
fprintf('Calculating residual Correlation and PNR imges...\n');
[Cn,PNR] = update_coor(neuron);

neuron.Cnr=Cn;
neuron.PNRr=PNR;
end




function [Cn,PNR] = update_coor(neuron);
n_enhanced=neuron.n_enhanced;
Y = neuron.load_patch_data();

d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
gSiz=gSig*4;

if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
Y(isnan(Y)) = 0;    % remove nan values
T = size(Y, 2);

%% substract neurons

if isa(Y,'uint8')
    Y=Y-uint8(full(neuron.A)*neuron.C);
else
    Y=Y-uint16(full(neuron.A)*neuron.C);
end



if isempty(neuron.options.F)
    F=T;
else
    F=neuron.options.F;
end

%% preprocessing data
% create a spatial filter for removing background
if n_enhanced==0
    if neuron.options.center_psf
        psf = fspecial('gaussian', ceil(gSiz+1), gSig);
        ind_nonzero = (psf(:)>=max(psf(:,1)));
        psf = psf-mean(psf(ind_nonzero));
        psf(~ind_nonzero) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig);
    end
else
    psf = [];
end

% filter the data
if isempty(psf)
    % no filtering
    HY = Y;
else
    HY = imfilter(reshape(single(Y), d1,d2,[]), psf, 'replicate');
end

HY = reshape(single(HY), d1*d2, []);
%% PV Remove media in each session
if size(F,1)>1
    t=0;
    for i=1:size(F,1)
        HY(:,t+1:t+F(i)) = HY(:,t+1:t+F(i))-median(HY(:,t+1:t+F(i)),2);
        t=F(i);
    end
else
    HY = bsxfun(@minus, HY, median(HY, 2));
end
if size(HY,2)>10000
    Sn=GetSn_fast(HY,1000,10,d1,d2);
else
    Sn=GetSn(HY);
end

[~,Cn,PNR]=get_PNR_coor_greedy_PV(reshape(HY, d1,d2,[]),0,F,Sn,n_enhanced);
end