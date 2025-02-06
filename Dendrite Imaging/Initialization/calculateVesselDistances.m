function distanceMatrix = calculateVesselDistances(labeledImage)
%calculateVesselDistances Calculates a distance matrix between labeled 
%                          connected components in an image using parallel
%                          computing.
%
%   distanceMatrix = calculateVesselDistances(labeledImage)
%
%   Input:
%       labeledImage: A labeled image where each connected component 
%                     (e.g., vessel) is assigned a different integer label.
%
%   Output:
%       distanceMatrix: A square matrix where each element (i, j) represents 
%                      the minimum distance between the connected components 
%                      with labels i and j.


numVessels = max(labeledImage(:));
distanceMatrix = zeros(numVessels, numVessels);

% Pre-calculate all distance transforms
distTransforms = cell(numVessels, 1);
parfor i = 1:numVessels  % Use parfor for parallel computation
    distTransforms{i} = bwdist(labeledImage == i);
end

for i = 1:numVessels 
    for j = i+1:numVessels 
        distanceMatrix(i, j) = min(distTransforms{i}(labeledImage == j));
    end
end

% Fill the lower triangle (symmetric matrix)
distanceMatrix = distanceMatrix + distanceMatrix'; 

% Set diagonal to 0 (distance to itself)
distanceMatrix(1:numVessels+1:end) = 0; 

end
