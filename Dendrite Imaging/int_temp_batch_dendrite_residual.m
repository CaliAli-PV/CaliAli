function [A,C_raw,C,S] = int_temp_batch_dendrite_residual(neuron)
%int_temp_batch_dendrite Initializes dendrite components from calcium 
%                         imaging data. This function is likely part of a 
%                         larger pipeline for applying CNMF (constrained 
%                         non-negative matrix factorization) to calcium 
%                         imaging data.
%
%   [A, C_raw, C, S, Ymean] = int_temp_batch_dendrite(neuron)
%
%   Input:
%       neuron:  CNMF-E neuron object.
%
%   Outputs:
%       A:       Spatial components..
%       C_raw:   Raw temporal components (calcium activity traces).
%       C:       Deconvolved temporal components.
%       S:       Spike trains inferred from the calcium activity.
%       Ymean:   Average or median values of the calcium imaging data.


%% Get batch size and initialize variables
d1 = neuron.options.d1;         % Number of rows in the image
d2 = neuron.options.d2;         % Number of columns in the image
F = get_batch_size(neuron);     % Get the size of each batch
fn = [0, cumsum(F)];            % Cumulative sum of batch sizes
Ymean = cell(1, size(fn, 2)-1); % Initialize cell array for average values
A_T=cell(1, size(fn, 2)-1);
C_T=cell(1, size(fn, 2)-1);
C_raw_T=cell(1, size(fn, 2)-1);
S_T=cell(1, size(fn, 2)-1);

%% Loop through each batch
for i = progress(1:size(fn, 2)-1) 
    Y = neuron.load_patch_data([], [fn(i)+1, fn(i+1)]); % Load data for the current batch
                % Calculate median value for the batch
    
    %Caluculate residual video
    Y=single(reshape(Y,d1*d2,[]))-single(full(neuron.A)*neuron.C_raw(:,fn(i)+1:fn(i+1)));
    Y = Y-single(reshape(reconstruct_background_residual(neuron,[fn(i)+1,fn(i+1)]), [], size(Y,2)));
  
    % Reshape data if necessary
    if ~ismatrix(Y)
        Y = single(reshape(Y, d1*d2, [])); % Convert 3D movie to a matrix
    end
    Y(isnan(Y)) = 0;    % Remove NaN values

    % Screen seeding pixels as center of the neuron
    if isempty(neuron.CaliAli_options.cnmf.seed_mask)
        neuron.CaliAli_options.cnmf.seed_mask = true(d1, d2); % Use all pixels as potential seeds if no mask is provided
    end

    %% Initialize segmentation and component extraction
    [labeled_all, ~] = get_refined_dendrite_segmentations( ...
        neuron.Cnr, ...
        neuron.CaliAli_options.cnmf.min_dendrite_size, ...
        neuron.CaliAli_options.cnmf.dendrite_initialization_threshold, ...
        neuron.CaliAli_options.cnmf.seed_mask); % Segment dendrites

    A = [];  % Initialize spatial components
    C = [];  % Initialize temporal components
    C_raw = []; % Initialize raw temporal components
    S = [];  % Initialize spike trains

    %% Iteratively extract dendrite components
    while true
            seed = get_far_neighbors_dendrite(labeled_all, neuron); % Select seed pixel

            % Create a mask for the current seed
            mask = ismember(labeled_all, seed);
            current = labeled_all; 
            current(~mask) = 0;
            labeled_all = labeled_all - current; % Remove current seed from labeled regions
            labeled_all = adjust_seed(labeled_all); % Adjust seed labels

            % Extract mini videos around the seed
            [Y_box, ind_nhood, comp_mask, sz, ~] = get_mini_videos_dendrite(Y, current, neuron, neuron.CaliAli_options.inter_session_alignment.Cn,seed);
            if isempty(Y_box)
                break;  % Exit loop if no more mini videos can be extracted
            end

            % Estimate components for the mini video
            [a, c_raw] = estimate_components_dendrite(Y_box, comp_mask, sz, size(Y, 2));
            [c, s] = deconv_PV(c_raw, neuron.CaliAli_options.cnmf.deconv_options); % Deconvolve calcium traces

            %% Filter and expand spatial components
            a = expand_A(a, ind_nhood, d1*d2); % Expand spatial components to full image size
            Y = Y - a*c;  % Subtract estimated component from data

            % Concatenate components and spike trains
            A = cat(2, A, a);
            C = cat(1, C, c);
            C_raw = cat(1, C_raw, c_raw);
            S = cat(1, S, s);

            if sum(labeled_all) == 0
                break; % Exit loop if all labeled regions have been processed
            end
    end
    
    A_T{i}=A;
    C_T{i}=C;
    C_raw_T{i}=C_raw;
    S_T{i}=S;
end

%% Combine results from all batches
C = cat(2, C_T{:});
C_raw = cat(2, C_raw_T{:});
S = cat(2, S_T{:});

% Remove components with no spikes
kill = sum(S, 2) == 0;
C(kill, :) = [];
C_raw(kill, :) = [];
S(kill, :) = [];

% Adjust spike trains and spatial components
ix = true(size(S_T{1}, 1), 1);
ix(kill) = false;
S_T = cellfun(@(x) x(ix, :), S_T, 'UniformOutput', false);
A_T = cellfun(@(x) x(:, ix, :), A_T, 'UniformOutput', false);

% Calculate weights for averaging spatial components
weights = cellfun(@(x) mean(x, 2), S_T, 'UniformOutput', false);
weights = cat(2, weights{:});
weights = weights.^2;
weights = weights./sum(weights, 2);

% Average spatial components
A = A_T{1, 1}*0;
for i = 1:size(weights, 2)
    A = A + A_T{1, i}.*weights(:, i)';
end
A = mean(cat(3, A_T{:}), 3);

% Remove empty spatial components
kill = sum(A > 0) == 0;
A(:, kill) = [];
C(kill, :) = [];
C_raw(kill, :) = [];
S(kill, :) = [];
end

function labeled_all = adjust_seed(labeled_all)
%adjust_seed Adjusts the labels in a labeled image to ensure they are 
%            contiguous.
    
uniqueLabels = unique(labeled_all(:));  % Get unique labels
% Create a mapping from old labels to new labels
mapping = containers.Map(uniqueLabels, 0:length(uniqueLabels)-1); 
% Apply the mapping to scale the labels
labeled_all = arrayfun(@(x) mapping(x), labeled_all);
end