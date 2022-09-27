function [aligned_neurons,aligned_probabilities,reg_prob]=compute_cell_register_cluster(correlation_matrices,distance_links,overlap_links,...
    distance_metrics,similarity_pref,weights,method,max_dist,max_miss,min_prob,single_corr,corr_thresh,use_spatial,min_num_neighbors,...
chain_prob,binary_corr,max_sess_dist,centroids,scale_factor,reconstitute,similarity_id)


%% Track cells through multiple recordings
% input:
%   correlation_matrices: cell array containing correlation on overlap
%       between recordings and links
%   distance_links: centroid distance between neurons in recordings and
%       connecting recordings
%   distance_metrics: distances between neurons in each recording, for each
%       similarity metric (except temporal correlation)
%   similarity_pref: cell array of similarity preferences for each similarity metric
%       ('low' or 'high') 
%   weights: weights for simlarity metrics
%   method: probability assignment method,
%       ('Kmeans','gmm','gemm','glmm','percentile','default')
%   max_dist: maximum distance between centroids for identification
%   max_miss: maximum number of missed sesssions for neuron tracking
%   min_prob: minimal probability for identification between sessions
%   single_corr: default false, set true if connections are constructed
%       using Combine_Full_Experiment_pairwise_search
%   corr_thresh: minimal correlation on connections acceptable for
%        identification of neurons (usually zero unless binary_corr_prob is
%        true)
%   use_spatial: construct chains using spatial info from non-consecutive
%       sessions, this should be true if session registration across all
%       sessions is acceptable
%   min_num_neighbors: constant factor governing minimal number of neighbors for
%       mixture model decomposition in terms of total neurons per session
%   chain_prob: minimal probability for each chain of neurons
%   binary_corr: Treat correlation on connections as binary variable based
%       on corr_thresh as threshold. Used if more neuron identifications
%       are desired, or recording registration is poor.
%   max_sess_dist: (positive int) maximum distance between sessions for calculating
%       similarity. Set as [] for no maximum. Choosing a lower maximum
%       decreases calculation time but also may decrease accuracy
% output:
%   aligned_neurons: matrix of cells tracked through recordings
%   aligned_probabilities: chain probabilities for each cell
%% Author: Kevin Johnston, University of California, Irvine.


%Parameters

if ~exist('min_num_neighbors','var')||isempty(min_num_neighbors)
    min_num_neighbors=false;
end

size_vec=[];
for i=1:length(distance_metrics)
    size_vec(i)=size(distance_metrics{1,i}{1},2);
end

if weights(1)==0
    use_corr=false;
else
    use_corr=true;
end
if ~exist('penalty','var')||isempty(penalty)
    penalty=min_prob/2;
end

distance_vals=cell(size(distance_metrics));
%Construct probabilities between consecutive recordings
disp('Constructing Pairwise Distances Between Consecutive Sessions For All Metrics')
% aligned=cell(size(distance_metrics,1),size(distance_metrics,2))
% correlation=cell(size(distance_metrics,2));
% temp_dist=cell(size(correlation))
% corr_prob=cell(size(correlation))
% distance_prob=cell(size(correlation))
% max_pixel_dist=zeros(size(aligned));
aligned=cell(length(size_vec)-1,length(size_vec));

 parfor i=1:size(distance_metrics,1)
%     for i=1:size(distance_metrics)
  [aligned1{i},correlation{i},temp_dist{i},corr_prob{i},distance_prob{i},max_pixel_dist1(i)]=compute_aligned_pairwise_probability_single_full(...
        correlation_matrices(2*i-1:2*i),distance_links(2*i-1:2*i),overlap_links(2*i-1:2*i),distance_metrics{i,i}{1},distance_metrics{i,i+1},...
        similarity_pref,max_dist,use_corr,single_corr,method,corr_thresh,min_num_neighbors,min_prob,similarity_id);
   
end
%This can be replaced with a reshape function to save memory.
for i=1:size(distance_metrics,1)
    aligned{i,i+1}=aligned1{i};
    max_pixel_dist(i,i+1)=max_pixel_dist1(i);
end
clear aligned1;
clear max_pixel_dist1;


disp('Constructing Initial Tracking Matrices')
%construct weighted identification probabilities, perform stochastic
%update, normalized probabilities

for i=1:size(distance_metrics,1)
    
 
    distance_vals{i,i+1}=temp_dist{i};
    corr_prob{i}(mean(correlation{i},2)<=corr_thresh&~isnan(corr_prob{i}))=0;
    %corr_prob{i}(isnan(corr_prob{i}))=0;
    if binary_corr
        corr_prob{i}(mean(correlation{i},2)<=corr_thresh)=0;
        corr_prob{i}(mean(correlation{i},2)>corr_thresh)=1;
 
    end
    
    for j=1:length(distance_prob{i})
        distance_prob{i}{j}(isnan(distance_prob{i}{j}))=0;
    end
    bad_ind=max(cat(1,distance_prob{i}{:,1:3}),[],1)==0;
    for j=4:length(distance_prob{i})
        if weights(j)>0
            distance_prob{i}{j}=edit_low_similarity(aligned{i,i+1},distance_prob{i}{j},min_prob);

            distance_prob{i}{j}(bad_ind)=0;
        end
    end
    
    
    corr_prob{i}(bad_ind)=0;
    %temp_weights=weights;
    %temp_weights(1)=0;
    %temp_weights=temp_weights/sum(temp_weights);
    try
        corr_prob{i}=adjust_identical_probabilities(corr_prob{i},aligned{i,i+1},correlation{i},'high');
        
    end
    for j=1:length(distance_prob{i})
        distance_prob{i}{j}=adjust_identical_probabilities(distance_prob{i}{j},aligned{i,i+1},distance_vals{i,i+1}{j},similarity_pref{j});
    end
    
    
    probabilities{i,i+1}=extract_weighted_probabilities(weights,corr_prob{i},distance_prob{i});
    %temp_prob{i,i+1}=extract_weighted_probabilities(temp_weights,corr_prob{i},distance_prob{i});
    prob{i,i+1}={weights,corr_prob{i},distance_prob{i}};
    probabilities{i,i+1}=adjust_identical_probabilities(probabilities{i,i+1},aligned{i,i+1},distance_vals{i,i+1}{2},'high');
    %    probabilities{i,i+1}=corr_prob{i}*weights(1);
    %else
    %    probabilities{i,i+1}=zeros(size(distance_prob{i}{1},2),1);
    %end
    %for j=1:length(distance_prob{i})
    %    probabilities{i,i+1}=probabilities{i,i+1}+weights(j+1)*distance_prob{i}{j}';
    %    probabilities{i,i+1}(isnan(probabilities{i,i+1}))=0;
    %end
    
    ind_del=find(probabilities{i,i+1}<min_prob);
    
    
    
    aligned{i,i+1}(ind_del,:)=[];
    
    probabilities{i,i+1}(ind_del)=[];
    try
        corr_prob{i}(ind_del)=[];
    end
    for p=1:length(distance_prob{i})
        try
            distance_prob{i}{p}(ind_del)=[];
        end
    end
    prob{i,i+1}={weights,corr_prob{i},distance_prob{i}};
  
    for p=1:sum(weights(2:end)>0)
        try
        distance_vals{i,i+1}{p}(ind_del)=[];
        end
    end
   try
    %    probabilities{i,i+1}=main_stochastic_optimization(pair_aligned{i},probabilities{i,i+1},min_prob);
   end
    
end


if ~use_spatial 
    [aligned_neurons,aligned_probabilities]=...
        construct_tracking_matrices_no_spatial_kmedoids(aligned,probabilities,prob,size_vec,min_prob,distance_metrics);
    [aligned_neurons,aligned_probabilities]=...
    Remove_Repeats_adj(aligned_neurons,aligned_probabilities,size_vec,use_spatial,probabilities,aligned,min_prob,distance_vals,max_miss,max_sess_dist,chain_prob);

end


if use_spatial&sum(weights(2:end))>0&length(distance_metrics)>2
disp('Construct Spatial Distances Between All Available Sessions')


%Parallelize this across both loops later.
%Construct identification probabilities for all recording pairs

weights(2:end)=weights(2:end)/sum(weights(2:end)); 
weights(1)=0;
parfor p=1:size(distance_metrics,1)*size(distance_metrics,2);
    [i,j]=ind2sub([size(distance_metrics,1),size(distance_metrics,2)],p);
    if j>i+1 & j<=i+max_sess_dist
% for i=1:size(distance_metrics,1)
%     spat_temp=cell(1,length(distance_metrics));
%     corr_temp=cell(size(spat_temp));
%     distance_temp_vals=cell(size(spat_temp));
%     corr_prob_temp=cell(size(spat_temp));
%     dist_prob_temp=cell(size(spat_temp));
%     temp_prob=cell(size(spat_temp));
%     for j=i+2:min(length(distance_metrics),max_sess_dist+i)
%         if isempty(max_sess_dist)||(j-i<=max_sess_dist)
%           [spat_temp{j},corr_temp{j},distance_temp_vals{j},corr_prob_temp{j},dist_prob_temp{j},max_pixel_dist(i,j)]=compute_aligned_pairwise_probability_single_full(...
%                 [],[],distance_metrics{i,i}{1},distance_metrics{i,j},...
%                 similarity_pref,max_dist,false,single_corr,method,corr_thresh,min_num_neighbors);
            [aligned{p},~,distance_vals{p},~,distance_prob,max_pixel_dist]=compute_aligned_pairwise_probability_single_full(...
        [],[],[],distance_metrics{i,i}{1},distance_metrics{i,j},...
        similarity_pref,max_dist,false,single_corr,method,corr_thresh,min_num_neighbors,min_prob,similarity_id);

      for l=1:length(distance_prob)
          distance_prob{l}=adjust_identical_probabilities(distance_prob{l},aligned{p},distance_vals{p}{l},similarity_pref{l});
      end
      bad_ind=max(cat(2,distance_prob{:,1:3}),[],2)==0;
      for pp=4:length(distance_prob)
          if weights(pp)>0
          distance_prob{pp}=edit_low_similarity(aligned{p},distance_prob{pp},min_prob);
          distance_prob{pp}(bad_ind)=0;
          end
      end
  
      probabilities{p}=extract_weighted_probabilities(weights,[],distance_prob);
      probabilities{p}=adjust_identical_probabilities(probabilities{p},aligned{p},distance_vals{p}{2},'high');
  
      ind_del=find(probabilities{p}<min_prob);
      probabilities{p}(ind_del)=[];
      
      aligned{p}(ind_del,:)=[];
      
      for q=1:length(distance_prob)
          try
            distance_prob{q}(ind_del)=[];
          end
          try
            distance_vals{p}{q}(ind_del)=[];
          end
      end
      prob{p}={weights,[],distance_prob};
%       for k=1:length(dist_prob_temp{j})
%           try
%                 dist_prob_temp{j}{k}(isnan(dist_prob_temp{j}{k}))=0;
%                 temp_prob{j}=temp_prob{j}+weights(k+1)*dist_prob_temp{j}{k}';
%           end
%     end
%     try
%     ind_del=find(temp_prob{j}<min_prob);
%     end
%     
%     try
%     spat_temp{j}(ind_del,:)=[];
%     
%     temp_prob{j}(ind_del)=[];
%     for p=1:length(distance_temp_vals{j})
%         distance_temp_vals{j}{p}(ind_del)=[];
%     end
%     end
%     %try
%     %    temp_prob{j}=main_stochastic_optimization(spat_temp{j},temp_prob{j},min_prob);
%     %end
%     temp_prob_curr=temp_prob{j};
% 
% 
%     try
%     ind_del=find(temp_prob{j}<min_prob);
%     
%     
%     
%     spat_temp{j}(ind_del,:)=[];
%     
%     temp_prob{j}(ind_del)=[];    
%     end   
%         else
%             spat_temp{j}=[];
%             temp_prob{j}=[];
%             distance_temp_vals{j}=cell(1,sum(weights(2:end)>0));
%         end
%     end
%     spat_aligned_temp{i}=spat_temp;
%     spat_prob{i}=temp_prob;
%     temp_vals{i}=distance_temp_vals;
%     
%     
    end
end


% for i=1:length(distance_metrics)
%     for j=i+2:length(distance_metrics)
%         aligned{i,j}=spat_aligned_temp{i}{j};
%         probabilities{i,j}=spat_prob{i}{j};
%         probabilities{i,j}=adjust_identical_probabilities(probabilities{i,j},aligned{i,j},distance_metrics{i,j}{2});
%         prob{i,j}={weights,{},spat_prob{i}{j}};
%         distance_vals{i,j}=temp_vals{i}{j};
%     end
% end


vals=max_pixel_dist(max_pixel_dist>0);
max_pixel_dist(max_pixel_dist>prctile(vals,90))=prctile(vals,90);
max_pixel_dist(max_pixel_dist<prctile(vals,10)&max_pixel_dist>0)=prctile(vals,10);
max_pixel_dist=scale_factor*max_pixel_dist;
max_pixel_dist(end+1,:)=0;
for l=1:size(max_pixel_dist,1)
    for q=l+1:size(max_pixel_dist,2)
        if max_pixel_dist(l,q)==0
            temp=[max_pixel_dist(l,:),max_pixel_dist(:,q)'];
            temp(temp==0)=[];
            max_pixel_dist(l,q)=mean(temp);
        end
    end
end
max_pixel_dist=max_pixel_dist+max_pixel_dist';
for l=1:size(max_pixel_dist,2)
    max_pixel_dist(l,l)=(sum(max_pixel_dist(l,l+1:end))+sum(max_pixel_dist(1:l-1,l)))/(size(max_pixel_dist,2)-1);
end
[aligned_neurons,aligned_probabilities,reg_prob]=construct_tracking_matrices_kmedoids(aligned,probabilities,...
    min_prob,chain_prob,distance_vals,max_sess_dist,size_vec,method,penalty,max_miss,max_pixel_dist,distance_metrics,centroids,reconstitute,prob);
disp('Removing Possible Repeats')
[aligned_neurons,aligned_probabilities]=...
    Eliminate_Repeats_No_Fill(aligned_neurons,reg_prob);


elseif use_spatial
[aligned_neurons,aligned_probabilities,reg_prob]=construct_tracking_matrices_kmedoids(aligned,probabilities,...
    min_prob,chain_prob,distance_vals,max_sess_dist,size_vec,method,penalty,max_miss,max_pixel_dist,distance_metrics,centroids,reconstitute,prob);
[aligned_neurons,aligned_probabilities]=...
    Eliminate_Repeats_No_Fill(aligned_neurons,reg_prob);

end

 





if size(aligned_probabilities,2)>1    
    aligned_probabilities(aligned_probabilities==0)=nan;
    aligned_probabilities=min(aligned_probabilities,[],2,'omitnan');
    aligned_probabilities(isnan(aligned_probabilities))=0;
end



   















%Delete neurons that span insufficient recording sessions
aligned_probabilities=round(aligned_probabilities,4);
aligned_probabilities(aligned_probabilities>1)=1;
rem_ind=find(sum(iszero(aligned_neurons),2)>max_miss);
rem_ind1=find(sum(aligned_neurons,2)==0);
rem_ind=[rem_ind;rem_ind1];
aligned_neurons(rem_ind,:)=[];
aligned_probabilities(rem_ind,:)=[];
try
reg_prob(rem_ind,:)=[];
catch
    reg_prob=[];
end


end
