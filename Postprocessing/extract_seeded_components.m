function [A, C_raw, C, S] = extract_seeded_components(Y, HY, seed_all, neuron, psf, n_enhanced)
%% extract_seeded_components: Extract one component per seed, removing each as it goes.
%
% The loop shared by every residual update, so that seeding from the residual
% and seeding from the raw signal cannot drift apart. Seeds are taken a
% well-separated group at a time; each extracted component is deconvolved and
% SUBTRACTED from both the raw and the filtered data before the next group.
% That subtraction is what lets a neuron masked by a brighter neighbour be
% estimated on a later seed against data that no longer contains the neighbour.
% Without it, overlapping neurons are fitted against each other.
%
% Inputs:
%   Y           - d1*d2 x T raw data, integer type, modified as extraction proceeds
%   HY          - d1*d2 x T filtered data, single
%   seed_all    - linear pixel indices to seed from
%   neuron      - Sources2D object, for options and geometry
%   psf         - point-spread kernel used to filter a footprint before it is
%                 removed from HY. Empty when the data was neuron-enhanced,
%                 in which case HY is unfiltered and the footprint is removed
%                 as it is.
%   n_enhanced  - neuron enhancement setting; 0 means the data was not enhanced
%
% Outputs:
%   A      - d1*d2 x K footprints
%   C_raw  - K x T raw traces
%   C      - K x T deconvolved traces
%   S      - K x T spikes
%
% Author: Pablo Vergara

d1 = neuron.options.d1;
d2 = neuron.options.d2;
A = []; C = []; C_raw = []; S = [];
while true
    seed = get_far_neighbors(seed_all, neuron);
    seed_all(ismember(seed_all, seed)) = [];

    [Y_box, HY_box, ind_nhood, center, sz] = get_mini_videos(Y, HY, seed, neuron);
    if isempty(Y_box)
        break
    end
    [a, c_raw] = estimate_components(Y_box, HY_box, center, sz, neuron, size(Y, 2));
    [c, s] = deconv_PV(c_raw, neuron.options.deconv_options);

    %% Filter a
    af = a;
    if n_enhanced == 0
        parfor k = 1:size(a, 2)
            if ~isempty(a{k})
                temp = imfilter(reshape(a{k}, sz{k}(1), sz{k}(2)), psf, 'replicate');
                af{1, k} = temp(:);
            else
                af{1, k} = [];
            end
        end
    end
    a = expand_A(a, ind_nhood, d1 * d2);
    af = expand_A(af, ind_nhood, d1 * d2);
    af(af < 0) = 0;

    %% update video;
    if isa(Y, 'uint8')
        Y = Y - uint8(a * c);
    else
        Y = Y - uint16(a * c);
    end
    HY = HY - single(af * c);

    A = cat(2, A, a);
    C = cat(1, C, c);
    C_raw = cat(1, C_raw, c_raw);
    S = cat(1, S, s);

    if isempty(seed_all)
        break
    end
end
end
