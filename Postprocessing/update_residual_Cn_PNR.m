function neuron=update_residual_Cn_PNR(neuron)
fprintf('Calculating residual Correlation and PNR imges...\n');
[Cn,PNR] = update_coor(neuron);

neuron.Cnr=Cn;
neuron.PNRr=PNR;
end


function [Cn,PNR] = update_coor(neuron);
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.n_enhanced;
gSiz=gSig*4;
fn=[0,cumsum(neuron.options.F)];
for i=progress(1:size(fn,2)-1)
    Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);

    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values
    Y=v2uint8(single(Y)-single(neuron.A*neuron.C(:,fn(i)+1:fn(i+1))));
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

    HY = bsxfun(@minus, HY, median(HY, 2));
    %% Get PNR and CN PV

    [~,Cn_all(:,:,i),PNR_all(:,:,i)]=get_PNR_coor_greedy_PV(reshape(HY,d1,d2,[]),0,[],[],n_enhanced);
end
Cn=mat2gray(medfilt2(max(Cn_all,[],3)));
PNR=mat2gray(max(PNR_all,[],3));
end