function correlation_matrices=construct_correlation_matrix(neurons,links,overlap,max_dist)
%Construct correlations between extracted sessions and extracted
%connections
%inputs
%   neurons: cell array of extracted neural activity from each recording,
%       Sources2D
%   links: cell array of extracted neural activity from connections,
%       Sources2D
%   overlap: numerical, number of frames of overlap between recording and
%       the consecutive connection
%   max_dist: numerical, maximum distance between identified neuron
%       centroids
%outputs
%   correlation_matrices; cell array of correlation matrices
%Author: Kevin Johnston, University of California, Irvine


clear display_progress_bar
display_progress_bar('Constructing Correlation Matrices: ',false);
display_progress_bar(.01,false);
if isempty(overlap)
    overlap=size(neurons{1, 1}.C,2);
end
for i=1:length(neurons)-1
    temp1=neurons{i}.copy();
    temp1.C=neurons{i}.C(:,end-overlap+1:end);
    %temp1.S=neurons{i}.S(:,end-overlap+1:end);
    temp2=links{i}.copy();
    temp2.C=links{i}.C(:,1:overlap);
    %temp2.S=links{i}.S(:,1:overlap);
    %try
    %    C_corr=spike_train_correlation(temp1,temp2,[.5,.5],max_dist);
    %catch
        C_corr=corr(temp1.C',temp2.C');
    %end
    C_corr(isnan(C_corr))=0;
    
    
    display_progress_bar(100*(2*i-1)/((length(neurons)-1)*2),false);
    correlation_matrices{2*i-1}=C_corr;
    if i<=length(links)
    temp1=links{i}.copy();
    temp1.C=links{i}.C(:,end-overlap+1:end);
    %temp1.S=links{i}.S(:,end-overlap+1:end);
    temp2=neurons{i+1}.copy();
    temp2.C=neurons{i+1}.C(:,1:overlap);
    %temp2.S=neurons{i+1}.S(:,1:overlap);
    %try
    %    C_corr=spike_train_correlation(temp1,temp2,[.1],max_dist);
    %catch
    C_corr=corr(temp1.C',temp2.C');
    %end
    C_corr(isnan(C_corr))=0;
  
    correlation_matrices{2*i}=C_corr;
    display_progress_bar(100*2*i/((length(neurons)-1)*2),false);
    end
end
display_progress_bar(' Completed',false);
display_progress_bar('terminating',true)
