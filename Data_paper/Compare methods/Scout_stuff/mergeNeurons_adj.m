function [aligned_neurons,aligned_probabilities]=mergeNeurons_adj(aligned_neurons,...
    aligned_probabilities,probabilities,aligned,dist_vals,min_prob,method,penalty,max_sess_dist,use_spat,chain_prob);
%Merge neuron chains if every common element between chains is the same




temp_aligned=cell(1,size(aligned_neurons,1));
parfor i=1:size(aligned_neurons,1)
    
    
    if sum(aligned_neurons(i,:))>0
%         pos_ind=find(aligned_neurons(i,:)>0);
%         ind=find((sum((aligned_neurons(i,pos_ind)-aligned_neurons(:,pos_ind))==0,2)==max(length(pos_ind)));
%         if length(ind)>1
%             aligned_neurons(i,:)=0;
%         else
            ind=[];
            pos_ind=find(aligned_neurons(i,:)>0);
            ind=find(sum((abs(~iszero(aligned_neurons(i,:)-aligned_neurons))-xor(~iszero(aligned_neurons(i,:)),...
                ~iszero(aligned_neurons))),2)==0&sum(aligned_neurons(i,:)-aligned_neurons>0,2)>0&sum(aligned_neurons(i,:)-aligned_neurons<0,2)>0&...
                sum(aligned_neurons(i,pos_ind)==aligned_neurons(:,pos_ind),2)>0);
            ind(ind<i)=[];
            if length(ind)>0
                new_neurons=aligned_neurons(ind,:);
                new_neurons(:,pos_ind)=repmat(aligned_neurons(i,pos_ind),length(ind),1);
                new_prob=zeros(length(ind),size(aligned_probabilities,2));
                [new_neurons,new_prob]=Eliminate_Duplicates(new_neurons,new_prob);
                if use_spat
                    new_prob=construct_combined_probabilities_adj(new_neurons,probabilities,aligned,dist_vals,min_prob,[],[],max_sess_dist);
                elseif ~isempty(probabilities)
                    new_prob=construct_consecutive_probabilities(new_neurons,probabilities,aligned);
                end
                new_neurons(new_prob<chain_prob,:)=[];
                temp_aligned{i}=new_neurons;
            end   
        end
       
      
    
    end
    

aligned_neurons=[aligned_neurons;vertcat(temp_aligned{:})];
aligned_probabilities(end+1:size(aligned_neurons,1))=0;
[aligned_neurons,aligned_probabilities]=Eliminate_Duplicates(aligned_neurons,aligned_probabilities);

rem_ind=find(sum(iszero(aligned_neurons),2)==size(aligned_neurons,2));
aligned_neurons(rem_ind,:)=[];
aligned_probabilities(rem_ind,:)=[];
