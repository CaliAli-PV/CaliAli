function aligned_probabilities=construct_combined_probabilities_adj(aligned_neurons,probabilities,aligned,dist_vals,min_prob,method,penalty,max_sess_dist)
%Construct chain probabilities

%inputs
%method: (str) 'min_intergroup', 'mean_intergroup',
    %'min_max','mean_max,total_connected','individual_connected'
    %default 'min_max'
% aligned_neurons (matrix) current cell register
% probabilities (cell array) probabilities between all sessions
%pair_aligned (cell array) (consecutive session identifications)
%spat_aligned (cell array) (non-consecutive session identifications)
%dist_vals (cell array) metric distance between pairwise sessions
%min_prob (float range [0,1]) min acceptance probability between sessions
%penalty (float) penalty for missing neuron
%max_sess_dist (int) max distance between compared sessions

%outputs
%aligned_probabilities (array) chain probabilities for each row of cell
    %register.
    
%%Author Kevin Johnston
%% Parameter Setting


if ~exist('method','var')||isempty(method)
    method='individual_connected';
end
if ~exist('penalty','var')||isempty(penalty)
    penalty=min_prob/2;
end

aligned_probabilities=zeros(size(aligned_neurons,1),1);

%Probability construction
parfor i=1:size(aligned_neurons,1)
    if sum(~iszero(aligned_neurons(i,:)))>0
        
        
        
        total_prob=0;
        min_curr_prob=1;
        max_group=[];
        individual_connected=[];
        total_exceeding=0;
        total_pairs=0;
        tiebreaker=0;
        for j=1:size(aligned_neurons,2)
            index_prob=0;
            connected=0;
           
            for k=[1:j-1,j+1:size(aligned_neurons,2)]
               if isempty(max_sess_dist)||abs(k-j)<=max_sess_dist
                if j>k
                    index1=k;
                    index2=j;
                else
                    index1=j;
                    index2=k;
                end
                
                if ~iszero(aligned_neurons(i,index1))&~iszero(aligned_neurons(i,index2))
                    
                    
                        
                    
                        try
                            ind=find(aligned{index1,index2}(:,1)==aligned_neurons(i,index1)&aligned{index1,index2}(:,2)==aligned_neurons(i,index2));
                        catch
                            continue
                        end
                        if isempty(ind)
                            total_prob=total_prob+penalty;
                        else
                            total_prob=total_prob+probabilities{index1,index2}(ind);
                            index_prob=max(index_prob,probabilities{index1,index2}(ind));
                            total_exceeding=total_exceeding+1;
                            connected=connected+1;
                            if probabilities{index1,index2}(ind)<min_curr_prob
                                min_curr_prob=probabilities{index1,index2}(ind);
                            end
                            tiebreaker=tiebreaker+dist_vals{index1,index2}{1}(ind);
                        end
                        total_pairs=total_pairs+1;
                        
                        
                    
                end
            end
        end
        max_group=[max_group,index_prob];    
        individual_connected=[individual_connected,connected];
        end
        max_group=max_group(~iszero(aligned_neurons(i,:)));
        if isequal(method,'min_max');
            aligned_probabilities(i)=min(max_group);
        elseif isequal(method,'mean_max');
            aligned_probabilities(i)=mean(max_group);
        elseif isequal(method,'mean_intergroup')
            aligned_probabilities(i)=total_prob/total_pairs;
        elseif isequal(method,'total_connected')
            aligned_probabilities(i)=total_exceeding/total_pairs;
        elseif isequal(method,'individual_connected')
            if sum(~iszero(aligned_neurons(i,:)))>1&sum(~iszero(individual_connected))>0
                %Adding the additional portion allows for greater
                %differentiation when multiple similar probabilities are
                %obtained.
                ind=find(~iszero(aligned_neurons(i,:)));
                tiebreaker=tiebreaker/total_pairs;
                if isempty(max_sess_dist)
                    denominator=sum(~iszero(aligned_neurons(i,:)))-1;
                else
                    [m,I]=min(individual_connected(ind));
                    denominator=length(max(1,I-max_sess_dist):min(size(aligned_neurons,2),I+max_sess_dist))-1;
                end
                aligned_probabilities(i)=min(individual_connected(ind))/denominator+total_prob/total_pairs*10^(-2)-tiebreaker*10^(-7);
            elseif sum(~iszero(aligned_neurons(i,:)))==1
                aligned_probabilities(i)=1;
            else
                aligned_probabilities(i)=0;
            end
        else
            aligned_probabilities(i)=min_curr_prob;
        end
        
        
    else
        aligned_probabilities(i)=0;
    end
end
