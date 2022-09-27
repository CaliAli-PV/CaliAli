function rem_ind=Eliminate_Repeats(aligned_neurons,aligned_probabilities)
%Eliminate chains containing duplicate neurons (deprcated)
%input
%   aligned_neurons: matrix of neuron chains
%   aligned_probabilities: matrix of consecutive identification
%   probabilities
%output
%   rem_ind: index of chains to be eliminated

%%Author Kevin Johnston

%% Algorithm

rem_ind=zeros(1,size(aligned_neurons,1));

%aligned_probabilities(isnan(aligned_probabilities))=0;
if size(aligned_probabilities,2)>0
    probabilities=mean(aligned_probabilities,2,'omitnan');
end

%Greedy algorithm to retain best linkages
% 
num_sess=sum(~isnan(aligned_neurons),2);

for i=max(num_sess):-1:1
    while max(num_sess)==i
        avail_ind=find(num_sess==i);
        [~,I]=max(probabilities(num_sess==i));
        I=avail_ind(I);
        current_aligned=aligned_neurons(I,:);
        for k=1:size(aligned_neurons,2)
            ind=aligned_neurons(:,k)==current_aligned(k);
            ind(I)=0;
            rem_ind(ind)=1;
            num_sess(ind)=0;
            num_sess(I)=0;
            aligned_neurons(ind,:)=0;
        end
    end
end
rem_ind=find(rem_ind);

