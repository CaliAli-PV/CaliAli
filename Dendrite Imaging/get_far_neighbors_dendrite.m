function [out]=get_far_neighbors_dendrite(labeledImage,neuron)
gSig=neuron.CaliAli_options.downsampling.gSig;
PNR=neuron.CaliAli_options.inter_session_alignment.PNR;


seed=1:max(labeledImage,[],'all');
if numel(seed)>1
    di=min(gSig)*4*3;  %% maximum distance between neuron is 3 time the average neuron size
    %% Get pixel intensity
    D = calculateVesselDistances(labeledImage);
    D=D<di;

    for i=1:max(labeledImage,[],"all");
        intensisty(:,i)=mean((labeledImage==i).*PNR,'all');
    end

    %%
    out=[];
    while true
        if isempty(D)
            break
        end
        [~,I]=max(intensisty); %% get brightest seed (target seed).
        out=[out,seed(I)];
        %% remove seed too close to the target seed
        kill_seeds=logical(D(I,:));
        D(kill_seeds,:)=[];D(:,kill_seeds)=[];
        intensisty(kill_seeds)=[];
        seed(kill_seeds)=[];
        % Iterate until no seed are present
    end
else
    out=seed;
end

end


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



