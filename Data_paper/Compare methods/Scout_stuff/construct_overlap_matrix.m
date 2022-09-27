function overlaps=construct_overlap_matrix(neurons)
%Construct overlap distance between all neuron pairs extracted from
%different recordings
%inputs
%   neurons: cell array of extracted neural activity from each recording,
%       Sources2D

%outputs
%   overlaps: cell array of overlap matrices
%Author: Kevin Johnston, University of California, Irvine


total=0;
clear display_progress_bar
display_progress_bar('Constructing Overlap Matrices: ',false);
for i=1:length(neurons)-1
    for j=i:length(neurons) 
    temp=bsxfun(@times, neurons{i}.A, 1./sqrt(sum(neurons{i}.A.^2)));
    temp1=bsxfun(@times, neurons{j}.A, 1./sqrt(sum(neurons{j}.A.^2)));
    overlaps{i,j}=temp'*temp1;
    total=total+1;
     display_progress_bar((total/((length(neurons)+1)*(length(neurons))/2-1)*100),false);
    end
end
display_progress_bar(' Completed', false);
display_progress_bar('terminated',true);