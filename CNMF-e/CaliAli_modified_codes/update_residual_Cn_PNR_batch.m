function neuron=update_residual_Cn_PNR_batch(neuron)
fprintf('Calculating residual Correlation and PNR imges...\n');
[Cn,PNR] = update_coor(neuron);

neuron.Cnr=Cn;
neuron.PNRr=PNR;
end


function [Cn,PNR] = update_coor(neuron)
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.CaliAli_options.preprocessing.neuron_enhance  ;
fn=[0,cumsum(get_batch_size(neuron))];
for i=progress(1:size(fn,2)-1)
    Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);
    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values
    %% substract neurons
    A=full(neuron.A);
    Y=single(Y);
% Traces are stored in noise units after scale_to_noise; a residual needs them
% in movie units or the model subtracted is about six times too large.
    C_mu = trace_noise_scale(neuron, 'apply', neuron.C_raw);
    Y=Y-single(A*C_mu(:,fn(i)+1:fn(i+1)));
    Y = Y-single(reshape(reconstruct_background_residual(neuron,[fn(i)+1,fn(i+1)]), [], size(Y,2)));

    % labeledImage=spatial2labeledImage(neuron.A,[d1,d2]);
    %  Y(labeledImage(:)>0,:)=0;
    Y=reshape(Y,d1,d2,[]);

     Y=detrend_vid(Y,neuron.CaliAli_options);

    if strcmp(neuron.CaliAli_options.preprocessing.structure,'neuron')
        [~,Cn_all(:,:,i),pnr_all(:,:,i)]=get_PNR_coor_greedy_PV(Y,gSig,[],[],n_enhanced);
    elseif strcmp(neuron.CaliAli_options.preprocessing.structure,'dendrite')
        [Cn_all(:,:,i),pnr_all(:,:,i)]=get_PNR_Cn_dendrite(Y,neuron.CaliAli_options);
    end
end
% Cn_scale is the peak RAW correlation over the whole video. Dividing by it puts
% this image on the same scale as the correlation image the alignment stored, so
% min_corr means the same thing everywhere and a weak residual stays weak.
% Multiplying by max(Cn_all,'all')/Cn_scale instead made the result quadratic in
% the image -- raw^2/Cn_scale -- which inflated it by the ratio of its own peak
% to Cn_scale and let far too many pixels clear min_corr.
Cn=max(Cn_all,[],3)./neuron.CaliAli_options.inter_session_alignment.Cn_scale;
PNR=max(pnr_all,[],3);
end