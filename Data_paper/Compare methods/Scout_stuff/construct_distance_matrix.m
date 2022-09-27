



function distances=construct_distance_matrix(neurons)
%Construct centroid distance between all neuron pairs extracted from
%different recordings
%inputs
%   neurons: cell array of extracted neural activity from each recording,
%       Sources2D

%outputs
%   distances: cell array of centroid distance matrices
%Author: Kevin Johnston, University of California, Irvine


clear display_progress_bar
display_progress_bar('Constructing Distance Matrices ',false);
total=0;
for i=1:length(neurons)-1
    for j=i:length(neurons)  % modified by PV
    distances{i,j}=pdist2(neurons{i}.centroid,neurons{j}.centroid);
    total=total+1;
    display_progress_bar((total/((length(neurons)+1)*(length(neurons))/2-1)*100),false);
  
    
    end
end

display_progress_bar(' Completed',false);
display_progress_bar(' terminated',true);
