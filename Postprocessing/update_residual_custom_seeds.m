function neuron=update_residual_custom_seeds(neuron,seed_all_M)
%%
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.n_enhanced;
gSiz=gSig*4;
F=get_batch_size(neuron);
fn=[0,cumsum(F)];
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

    Y=uint16(reshape(Y,d1,d2,[]));


    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values

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
    Cn=neuron.Cnr;
    PNR=neuron.PNRr;

    %%
    % screen seeding pixels as center of the neuron
    Mask=neuron.options.Mask;

    %% Extract one component per seed, each removed from the data as it goes.
    % The loop lives in extract_seeded_components so that seeding from the raw
    % signal runs exactly the same procedure.
    [A, C_raw, C, S] = extract_seeded_components(Y, HY, seed_all_M, neuron, psf, n_enhanced);

    A_T{i}=A;
    C_T{i}=C;
    C_raw_T{i}=C_raw;
    S_T{i}=S;
end
I=cellfun(@(x) mean(x,2),S_T,'UniformOutput',false);
I=cat(2,I{:});
I=I./sum(I,2);
A=A_T{1, 1}*0;
for i=1:size(I,2)
    A=A+A_T{1, i}.*I(:,i)';
end

% The weighted merge above is the one to keep. Replacing it with a plain mean
% gives every batch the same say, so a batch where the component is silent
% contributes its noise on equal terms with a batch where it fires.
% (This line used to overwrite the weighted result with mean(cat(3,A_T{:}),3).)
C=cat(2,C_T{:});
C_raw=cat(2,C_raw_T{:});
S=cat(2,S_T{:});

kill=sum(S,2)==0;
A(:,kill)=[];
C(kill,:)=[];
C_raw(kill,:)=[];
S(kill,:)=[];

neuron.A=cat(2,neuron.A,A);
neuron.C=cat(1,neuron.C,C);
neuron.C_raw=cat(1,neuron.C_raw,C_raw);
neuron.S=cat(1,neuron.S,S);
% One new id per added component, starting ABOVE the current maximum.
% max(ids):max(ids)+n gives n+1 values and repeats the existing maximum, so the
% list grew longer than the component count and two components shared a key.
% Anything that looks a component up by id then takes the wrong one.
next = max([neuron.ids(:)', 0]);
neuron.ids = cat(2, neuron.ids, next + (1:size(A,2)));
if numel(neuron.tags) < size(neuron.A,2)
    neuron.tags = [neuron.tags(:); zeros(size(neuron.A,2)-numel(neuron.tags), 1, 'like', neuron.tags)];
end

end