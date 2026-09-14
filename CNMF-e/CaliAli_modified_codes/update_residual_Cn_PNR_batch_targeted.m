function neuron=update_residual_Cn_PNR_batch_targeted(neuron,prev_F)
fprintf('Calculating residual Correlation and PNR imges...\n');
[Cn,PNR] = update_coor(neuron,prev_F);

neuron.Cnr=Cn;
neuron.PNRr=PNR;
end


function [Cn,PNR] = update_coor(neuron,prev_F)
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.CaliAli_options.preprocessing.neuron_enhance  ;


[~,chunk]=get_batch_size(neuron);
F=neuron.CaliAli_options.inter_session_alignment.F;  % for debugging
F=cumsum(F);
batch=[linspace(0,prev_F,round((prev_F)/chunk)+1),...
    linspace(prev_F+1,F(end),round((F(end)-(prev_F))/chunk)+1)];
miss_B=find(batch>prev_F,1)-1;
for i=progress(miss_B:size(batch,2)-1)
    Y = neuron.load_patch_data([],[batch(i)+1,batch(i+1)]);
    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values
    Y=single(Y);
    % The same frames before anything is removed. Its peak is what the residual
    % image is scaled by, so both go through identical preprocessing.
    Y_raw=Y;
    %% substract neurons
    A=full(neuron.A);
% Traces are stored in noise units after scale_to_noise; a residual needs them
% in movie units or the model subtracted is about six times too large.
    C_mu = trace_noise_scale(neuron, 'apply', neuron.C_raw);
    Y=Y-single(A*C_mu(:,batch(i)+1:batch(i+1)));
    Y = Y-single(reshape(reconstruct_background_residual(neuron,[batch(i)+1,batch(i+1)]), [], size(Y,2)));

    % labeledImage=spatial2labeledImage(neuron.A,[d1,d2]);
    %  Y(labeledImage(:)>0,:)=0;
    Y=reshape(Y,d1,d2,[]);

     Y=detrend_vid(Y,neuron.CaliAli_options);
     Yr_raw=detrend_vid(reshape(Y_raw,d1,d2,[]),neuron.CaliAli_options);

    if strcmp(neuron.CaliAli_options.preprocessing.structure,'neuron')
        [~,Cn_all(:,:,i),pnr_all(:,:,i)]=get_PNR_coor_greedy_PV(Y,gSig,[],[],n_enhanced);
        [~,Cn_raw_all(:,:,i),~]=get_PNR_coor_greedy_PV(Yr_raw,gSig,[],[],n_enhanced);
    elseif strcmp(neuron.CaliAli_options.preprocessing.structure,'dendrite')
        [Cn_all(:,:,i),pnr_all(:,:,i)]=get_PNR_Cn_dendrite(Y,neuron.CaliAli_options);
        [Cn_raw_all(:,:,i),~]=get_PNR_Cn_dendrite(Yr_raw,neuron.CaliAli_options);
    end
end
Cn=max(Cn_all,[],3);
PNR=max(pnr_all,[],3);

% Apply whatever the alignment applied to its own projections, so the two images
% come out of the same chain of operations. Recorded by projection_session_stats.
med = [];
try med = neuron.CaliAli_options.inter_session_alignment.projection_median_filtering; catch; end
if ~isempty(med)
    Cn = medfilt2(Cn, med);
    PNR = medfilt2(PNR, med);
end

% SCALE. The residual correlation image is divided by the peak of the RAW
% correlation image OF THE SAME FRAMES, computed by the same function with the
% same preprocessing. min_corr then means the same fraction of peak here as it
% does at initialization, where the alignment divides its own image by its own
% peak (CaliAli_align_sessions, save_relevant_variables).
%
% It used to be divided by Cn_scale, the peak of the ALIGNMENT's projections.
% That is a different image: the alignment computes it on
% get_projections_and_detrend output, this computes it on detrend_vid output of
% the aligned recording. The ratio was therefore not a fraction of anything, and
% came out above 1 -- a residual image reaching 1.546 while min_corr was 0.2,
% which put the threshold five times below the image's own 99th percentile and
% seeded noise.
raw_peak = max(Cn_raw_all(:));
if ~isfinite(raw_peak) || raw_peak <= 0
    % Nothing to normalise against: leave the image in its own units rather than
    % dividing by zero and declaring every pixel a seed.
    warning('CaliAli:ResidualScale:NoRawPeak', ...
        ['The raw correlation image of these frames has no positive peak, so the ', ...
         'residual image cannot be put on a comparable scale. Leaving it unscaled; ', ...
         'min_corr will not mean what it means at initialization.']);
else
    Cn = Cn ./ raw_peak;
end
end