function [Y_box, ind_nhood, center, sz] = get_mini_videos_dendrite(Y, seed, neuron)
%GET_MINI_VIDEOS_DENDRITE Extracts mini-videos around seed points on a dendrite.
%
%   [Y_box, ind_nhood, center, sz] = get_mini_videos_dendrite(Y, seed, neuron)
%
%   Inputs:
%       Y           - Matrix of fluorescence traces (pixels x time).
%       seed        - Linear indices of seed points on the dendrite.
%       neuron      - Structure containing neuron parameters, including:
%                       - options.d1: Image height (number of rows).
%                       - options.d2: Image width (number of columns).
%                       - options.gSig: Gaussian sigma for neighborhood size.
%
%   Outputs:
%       Y_box       - Cell array of mini-videos (pixel values x time) around each seed.
%       ind_nhood  - Cell array of linear indices of pixels in each neighborhood.
%       center      - Cell array of linear indices of the center pixel in each neighborhood.
%       sz          - Cell array of sizes (rows x columns) of each neighborhood.

% Get image dimensions and Gaussian sigma from neuron structure
d1 = neuron.options.d1;
d2 = neuron.options.d2;
gSig = neuron.options.gSig;

% Calculate neighborhood size based on Gaussian sigma
if numel(gSig) < 2
    gSiz = [gSig * 6, gSig * 6];  % Use 6*sigma if only one sigma value is provided
else
    gSiz = gSig .* 4 * 1.5;       % Use 4*sigma*1.5 if two sigma values are provided 
end

% Initialize output cell arrays
Y_box = {};
HY_box = {}; % This seems unused in the code
ind_nhood = {};
center = {};
sz = {};

% Loop through each seed point
for k = 1:length(seed)
    ind_p = seed(k);  % Get linear index of the seed point
    y0 = Y(ind_p, :); % Get the fluorescence trace at the seed point

    % Check if the signal at the seed point is weak
    P = max(y0) / (median(abs(y0)) / 0.6745 * 3) < 1; 
    if P  % If signal is weak, skip this seed point
        ind_nhood{k} = [];
        HY_box{k} = [];
        Y_box{k} = [];
        center{k} = [];
        sz{k} = [];
        continue; 
    end

    % Convert linear index to row and column subscripts
    [r, c] = ind2sub([d1, d2], ind_p);

    % Define the neighborhood boundaries
    rsub = max(1, -gSiz(2) + r):min(d1, gSiz(2) + r);
    csub = max(1, -gSiz(1) + c):min(d2, gSiz(1) + c);

    % Create grid of row and column indices for the neighborhood
    [cind, rind] = meshgrid(csub, rsub);
    [nr, nc] = size(cind); 

    % Store neighborhood size
    sz{k} = [nr, nc];

    % Calculate linear indices of pixels in the neighborhood
    ind_nhood{k} = sub2ind([d1, d2], rind(:), cind(:));

    % Extract pixel values (fluorescence traces) within the neighborhood
    Y_box{k} = single(Y(ind_nhood{k}, :)); 

    % Calculate linear index of the center pixel within the neighborhood
    center{k} = sub2ind([nr, nc], r - rsub(1) + 1, c - csub(1) + 1); 
end

end