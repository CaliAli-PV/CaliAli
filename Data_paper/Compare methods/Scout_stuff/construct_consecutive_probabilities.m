function aligned_probabilities=construct_consecutive_probabilities(aligned_neurons,probabilities,pair_aligned,min_prob)
%Construct chain probabilities using consecutive probabilities

%Inputs

%aligned_neurons (matrix) current cell register
%probabilities (cell array) probability assignments between consecutive
    %sessions
% pair_aligned (cell array) Identifications between sessions
% min_prob (float range [0,1]) minimal probability for neuron
    % identification between sessions

%Outputs

%aligned_probabilities (matrix) chain  probabilities for cell register

%%Author Kevin Johnston

%%Construct chain probabilities


aligned_probabilities=zeros(size(aligned_neurons,1),1);
for i=1:size(aligned_neurons,1)
    if sum(~isnan(aligned_neurons(i,:)))>0
        total_pairs=0;
        total_prob=0;
        min_curr_prob=1;
        for j=1:size(aligned_neurons,2)-1
       
            if ~isnan(aligned_neurons(i,j))&~isnan(aligned_neurons(i,j+1))
                 
                        ind=find(pair_aligned{j}(:,1)==aligned_neurons(i,j)&pair_aligned{j}(:,2)==aligned_neurons(i,j+1));
                        if isempty(ind)
                            total_prob=total_prob+min_prob/2;
                        else
                            total_prob=total_prob+probabilities{j,k}(ind);
                            if probabilities{j,k}(ind)<min_curr_prob
                                min_curr_prob=probabilities{j,k}(ind);
                            end
                        end
                        
                        total_pairs=total_pairs+1;
                        
                        
                    end
                end
           
        
        %Switch to use mean probability over min probability
        aligned_probabilities(i)=total_prob/total_pairs;
        %aligned_probabilities(i)=min_curr_prob;
        
    else
        aligned_probabilities(i)=0;
    end
end
