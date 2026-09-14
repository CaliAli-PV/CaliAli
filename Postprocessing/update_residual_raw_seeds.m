function neuron = update_residual_raw_seeds(neuron, frame_range, ring_gsig, pct, min_null)
%UPDATE_RESIDUAL_RAW_SEEDS  Add components found in the raw signal, without duplicates.
%
%   neuron = update_residual_raw_seeds(neuron, frame_range, ring_gsig, pct, min_null)
%
%   An alternative to update_residual_custom_seeds for finding neurons that the
%   current model does not contain.
%
%   WHY NOT SEED FROM THE RESIDUAL. The residual inherits every error in the
%   model: a neuron that was not fitted perfectly leaves activity behind that
%   looks exactly like a new one, and the worse the model the less trustworthy
%   the residual becomes -- the wrong way round, because a poor model is when
%   new components are most needed. Measured on simulated recordings, seeding
%   from the residual placed 74 percent of its components where no neuron
%   exists, and tripled the component count in sessions it was not even adding
%   to.
%
%   WHAT THIS DOES INSTEAD. Components are initialized from the raw signal over
%   FRAME_RANGE with only the background removed, so their quality does not
%   depend on how well the existing components were fitted. That finds neurons
%   already in the model as well, so each candidate is then tested for being a
%   duplicate.
%
%   THE DUPLICATE TEST. For a candidate matched to an existing component, ask
%   whether the two are more alike than two DISTINCT neurons at that distance in
%   this tissue. The null is the spatio-temporal similarity between existing
%   components and those inside a ring of RING_GSIG neuron radii, measured from
%   the data rather than assumed.
%
%   A ring, not an overlap test: restricting the null to overlapping pairs would
%   leave it undefined in sparsely labelled tissue, which is where the decision
%   is easiest. If no two distinct neurons overlap anywhere, a candidate that
%   does overlap an existing one is the same neuron. The ring gives that for
%   free -- the null collapses towards zero and any resemblance becomes
%   significant -- while dense tissue yields a wider null and a higher bar.
%
%   RING_GSIG is the parameter that matters. Too small and there are too few
%   pairs to estimate a tail from; too large and the null is built from neurons
%   that could never be confused, all sitting at zero, which drags the
%   percentile down. Comparing a neuron with one thirty radii away says nothing
%   about duplication. Five to eight radii gave identical results on the test
%   recordings; below that there were too few pairs.
%
%   Measured against seeding from the residual on the same data: precision 0.67
%   against 0.12, 74 percent of the genuinely new neurons recovered, and no
%   duplicates in any replicate or setting.
%
%   Author: Pablo Vergara

if nargin < 3 || isempty(ring_gsig), ring_gsig = 5; end
if nargin < 4 || isempty(pct),       pct = 99;      end
if nargin < 5 || isempty(min_null),  min_null = 30; end

d1 = neuron.options.d1; d2 = neuron.options.d2;
gSig = neuron.options.gSig; gSiz = gSig*4;
ne = neuron.CaliAli_options.preprocessing.neuron_enhance;

%% ---- raw signal over the chosen frames, background removed only ---------
Y = neuron.load_patch_data([], frame_range);
if ~ismatrix(Y), Y = reshape(Y, d1*d2, []); end
Y(isnan(Y)) = 0; Y = single(Y);
Y = Y - single(reshape(reconstruct_background_residual(neuron, frame_range), [], size(Y,2)));
[~, Cn, PNR] = get_PNR_coor_greedy_PV(detrend_vid(reshape(Y, d1, d2, []), ...
    neuron.CaliAli_options), gSig, [], [], ne);

probe = neuron.CaliAli_options;
probe.inter_session_alignment.Cn = Cn;
probe.inter_session_alignment.PNR = PNR;
v_max = CaliAli_get_local_maxima(probe);
sm = neuron.CaliAli_options.cnmf.seed_mask;
if isempty(sm), sm = ones(size(Cn)); end
seed_all = find((v_max == Cn.*PNR) & (Cn >= neuron.options.min_corr) & ...
                (PNR >= neuron.options.min_pnr) & logical(sm));
if isempty(seed_all)
    fprintf('No raw seeds above threshold; nothing added.\n');
    return
end

%% ---- estimate each candidate -------------------------------------------
% Built exactly as update_residual_custom_seeds builds it: no kernel when the
% data was neuron-enhanced, in which case the filtered data is the data.
if ne == 0
    if neuron.options.center_psf
        psf = fspecial('gaussian', ceil(gSiz+1), gSig);
        ind_nz = (psf(:) >= max(psf(:,1)));
        psf = psf - mean(psf(ind_nz)); psf(~ind_nz) = 0;
    else
        psf = fspecial('gaussian', round(gSiz), gSig);
    end
else
    psf = [];
end
if isempty(psf)
    HY = single(Y);
else
    HY = imfilter(reshape(single(Y), d1, d2, []), psf, 'replicate');
end
HY = reshape(HY, d1*d2, []); HY = bsxfun(@minus, HY, median(HY, 2));
Yq = uint16(max(Y, 0));

[A_new, C_new, Cd_new, S_new] = extract_seeded_components(Yq, HY, seed_all, neuron, psf, ne);
if isempty(A_new), return; end

%% ---- the null, and the duplicate test ----------------------------------
A0 = full(neuron.A);
C0 = trace_noise_scale(neuron, 'apply', neuron.C_raw);
C0 = C0(:, frame_range(1):frame_range(2));
sA = unit_cols(A0); sC = unit_cols(C0')';
S0 = (sA' * sA) .* (sC * sC');
S0(1:size(S0,1)+1:end) = NaN;

[yy, xx] = ndgrid(1:d1, 1:d2);
w = sum(A0, 1) + 1e-12;
cy = (yy(:)' * A0) ./ w; cx = (xx(:)' * A0) ./ w;
in_ring = hypot(cy - cy.', cx - cx.') < ring_gsig*gSig;
in_ring(1:size(in_ring,1)+1:end) = false;
null_vals = S0(in_ring & ~isnan(S0));
if numel(null_vals) < min_null
    warning('CaliAli:RawSeedNullTooSmall', ...
        ['Only %d component pairs within %g neuron radii, fewer than the %d ', ...
         'needed to estimate a tail. Falling back to every pair in the field, ', ...
         'which includes neurons that could never be confused and makes the ', ...
         'test far stricter than intended. Consider a larger ring.'], ...
        numel(null_vals), ring_gsig, min_null);
    null_vals = S0(~isnan(S0));
end
thr = prctile(null_vals, pct);

sAn = unit_cols(A_new); sCn = unit_cols(C_new')';
best = max((sA' * sAn) .* (sC * sCn'), [], 1);
keep = best(:)' <= thr;
fprintf(['Raw seeding: %d candidates, %d duplicates rejected, %d added ', ...
         '(ring %g radii, %d null pairs, threshold %.3f).\n'], ...
    numel(keep), sum(~keep), sum(keep), ring_gsig, numel(null_vals), thr);
if ~any(keep), return; end

%% ---- append -------------------------------------------------------------
% Deconvolution already happened inside the extraction loop, where each
% component had to be deconvolved before it could be subtracted.
A_new = A_new(:, keep); C_new = C_new(keep, :);
c = Cd_new(keep, :); s = S_new(keep, :);
T = size(neuron.C, 2);
pad = @(X) [zeros(size(X,1), frame_range(1)-1), X, zeros(size(X,1), T-frame_range(2))];
neuron.A     = cat(2, neuron.A, A_new);
neuron.C     = cat(1, neuron.C, pad(c));
neuron.C_raw = cat(1, neuron.C_raw, pad(C_new));
neuron.S     = cat(1, neuron.S, sparse(pad(s)));
next = max([neuron.ids(:)', 0]);
neuron.ids  = cat(2, neuron.ids, next + (1:size(A_new,2)));
neuron.tags = [neuron.tags(:); zeros(size(A_new,2), 1, 'like', neuron.tags)];
end


function X = unit_cols(X)
X = full(X);
X = X ./ (sqrt(sum(X.^2, 1)) + 1e-12);
end
