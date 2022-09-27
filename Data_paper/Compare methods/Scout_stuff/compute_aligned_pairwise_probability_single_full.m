function [pair_aligned,correlation,distance_vals,corr_prob,distance_prob,max_pixel_distance]=...
    compute_aligned_pairwise_probability_single_full(correlation_matrices,distance_links,overlap_links,dist_self,...
    distance_metrics,similarity_pref,max_dist,use_corr,single_corr,method,corr_thresh,min_num_neighbors_factor,min_prob,similarity_id)


%% Construct identification probabilities across sessions
% input:
%   correlation_matrices: cell array containing 2 matrices giving
%       correlations between neurons and connecting recording.
%   distance_links: cell array, centroid distance between neurons in recordings and
%       connecting recordings
%   dist_self: matrix, centroid distance between neurons in single recording
%   distance_metrics: cell array, distances between neurons in each recording, for each
%       similarity metric (except temporal correlation)
%   similarity_pref: cell array of similarity preferences for each similarity metric
%       ('low' or 'high') 
%   
%   max_dist: numerical, maximum distance between centroids for identification
%   use_corr: boolean if true, use correlation on connecting recordings
%   min_prob: numerical, minimal probability for identification between sessions
%   single_corr: default false, set true if connections are constructed
%       using Combine_Full_Experiment_pairwise_search
%   corr_thresh: numerical, minimal correlation on connections acceptable for
%        identification of neurons (usually zero unless binary_corr_prob is
%        true)
%   
%   min_num_neighbors_factor: numerical, constant factor governing minimal number of neighbors for
%       mixture model decomposition in terms of total neurons per session
% Ouput:
%   pair_aligned: matrix, identified neurons between two sessions
%   correlation: matrix, correlation values for identified neurons on connnecting
%       recordings
%   distance_vals: cell array, distance for identified neurons between two sessions
%   corr_prob: matrix, correlation probabilities for identified neurons on
%       connecting recordings
%   distance_prob: cell array, distance probabilities for identified
%       neurons between two sessions
%   
%%Author: Kevin Johnston, University of California, Irvine.
%% Parameter Setting
if ~exist('min_num_neighbors_factor','var')||isempty(min_num_neighbors_factor)
    min_num_neighbors_factor=false;
end
if ~exist('max_dist','var')||isempty(max_dist)
    max_dist=16;
end
if ~exist('min_prob','var')||isempty(min_prob)
    min_prob=0;
end

if (~exist('use_corr','var')||isempty(use_corr))&~isempty(correlation_matrices)
    use_corr=true;
end

if ~exist('single_corr','var')||isempty(single_corr)
    single_corr=true;
end
if ~exist('method','var')||isempty(method)
    method='default';
end


corr_score=cell(1,size(distance_metrics{1},1));

correlation=cell(1,size(distance_metrics{1},1));

distance_score=cell(size(corr_score));
distance=cell(size(corr_score));


NN_distance=cell(1,length(distance_metrics));


NN_corr1=[];
NN_corr2=[];
NN_corr=[];
temp_aligned=[];

for j=1:size(dist_self,1)
    avail_ind=find(distance_metrics{1}(j,:)<max_dist);
    for i=1:length(distance_metrics)
        try
            NN_distance{i}=[NN_distance{i},distance_metrics{i}(j,avail_ind)];
        end
    end
end
if ~exist('min_num_neighbors_factor','var')
    min_num_neighbors_factor=1;
end

max_iter=15;
%Sort by centroid distance
[NN_distance{1},Ind]=sort(NN_distance{1});
for k=2:length(NN_distance)
    try
        NN_distance{k}=NN_distance{k}(Ind);
    end
end

%Eliminate neurons with zero overlap
if length(NN_distance)>1
    ind=find(NN_distance{2}==0);
    for p=1:length(NN_distance)
        try
            NN_distance{p}(ind)=[];
        end
    end
end




min_num_neighbors=min(ceil(size(distance_metrics{1},1)*min_num_neighbors_factor),length(NN_distance{1}));

%Limit data points based on kernel density
x=[];
BIC=[];
like=[];
JS=[];
options = statset('MaxIter',1000);
warning('off','all');
bins=0:.05:max(NN_distance{1});
bins=bins(1:end-1)+.025;
bw=optimal_bandwidth(NN_distance{1});
NN_distance{1}=NN_distance{1}+10^(-10); %ksdensity requires positivity
approx_dist=ksdensity(NN_distance{1},bins,'boundary','reflection','Support','positive','Bandwidth',bw);

if length(NN_distance{1})>0 

         local_min=find(islocalmin(approx_dist));
         min_coord=bins(local_min);
         min_coord(min_coord<2)=[];
        
         if ~isempty(min_coord)
             min_num_neighbors=min(min_num_neighbors,length(NN_distance{1}));
             x=max(min_coord(1)*2,NN_distance{1}(min_num_neighbors));
         elseif min_num_neighbors<length(NN_distance{1})
             x=max(2,NN_distance{1}(min_num_neighbors));
         else
             x=NN_distance{1}(end);
         end
        

    if min_num_neighbors<=length(NN_distance{1})
        max_pixel_distance=max(x,NN_distance{1}(min_num_neighbors));
    else
        max_pixel_distance=max(NN_distance{1})+.01;
    end
    
else
    pair_aligned=[];
    correlation=[];
    distance_vals=cell(1,length(distance_metrics));
    corr_prob=[];
    distance_prob=[];
    return
end

NN_distance{1}=NN_distance{1}(NN_distance{1}<max_pixel_distance);
vector_length=length(NN_distance{1});
for k=2:length(NN_distance);
    try
         NN_distance{k}=NN_distance{k}(1:vector_length);
    end
end


%Construct individual probability assignments for each metric
for i=1:length(distance_metrics)
    X=NN_distance{i};
    if isequal(similarity_id{i},'JS')
        
        X(X==1)=[];
    end
    use_temp=false;
    outliers=isoutlier(X);
    if ~isempty(X) & sum(abs(X(~outliers)-X(1))<10^(-5))~=sum(outliers==0)
        X(isoutlier(X))=[];
    end
%     if isequal(similarity_id{i},'decay')||isequal(similarity_id{i},'SNR')
%         %temp_method='gemm';
%         %use_temp=true;
%         if isequal(similarity_id{i},'decay')||isequal(similarity_id{i},'SNR')
%             X(isoutlier(X))=[];
%         end
%     end
    X(isnan(X))=[];
    if isempty(X)
        f_distance{i}=[];
    else
        if use_temp
            f_distance{i}=construct_probability_function_main(X,temp_method,similarity_pref{i});
            use_temp=false;
        else
            f_distance{i}=construct_probability_function_main(X,method,similarity_pref{i});
        end
     end
end
x=0:.01:max(NN_distance{1});
vals=f_distance{1}(x);
vals(vals<.5)=[];
link_pixel_distance=1.25*x(length(vals));


if use_corr
for j=1:size(dist_self,1)
    avail_ind=find(distance_metrics{1}(j,:)<max_pixel_distance);
    


    avail_ind1=find(distance_links{1}(j,:)<max_pixel_distance);
    if ~single_corr
        avail_ind2=[];
        for l=1:length(avail_ind)
            avail_ind2=[avail_ind2,find(distance_links{2}(:,avail_ind(l))'<max_pixel_distance)];
        end
        link_ind=intersect(avail_ind1,avail_ind2);
    else
        link_ind=[j];
    end
    for l=1:length(avail_ind)
        temp_aligned=[temp_aligned;[j,avail_ind(l)]];
        corr_score_max=[0,0];
        for k=1:length(link_ind)
            corr_score_temp=[correlation_matrices{1}(j,link_ind(k)),correlation_matrices{2}(link_ind(k),avail_ind(l))];
            if single_corr
                if mean(corr_score_temp)>mean(corr_score_max)
                    corr_score_max=corr_score_temp;
                end
                
            else
                if mean(corr_score_temp)>mean(corr_score_max)
                    corr_score_max=corr_score_temp;
                end
                
                
            end
            
        end
        if single_corr
            NN_corr2=[NN_corr2,corr_score_max(2)];
        else
            NN_corr1=[NN_corr1,corr_score_max(1)];
            NN_corr2=[NN_corr2,corr_score_max(2)];
            NN_corr=[NN_corr,mean(corr_score_max)];
        end
    end
end


end




if use_corr
    
    X=NN_corr2;
    X(X==0)=[];
    X(isoutlier(X))=[];
    %method='gmm';
    
    f_corr2=construct_probability_function_main(X,method,'right');
    
    if ~single_corr
        X=NN_corr1;
        X(X==0)=[];
        X(isoutlier(X))=[];
        f_corr1=construct_probability_function_main(X,method,'right');
    end
    
    
    
end





for i=1:size(dist_self,1)
    avail_ind=find(distance_metrics{1}(i,:)<max_pixel_distance);
    if isempty(avail_ind)
        for k=1:length(distance_metrics)
            distance_score{k}{i}=[];
            distance{k}{i}=[];
        end
        
        aligned{i}=[];
        corr_score{i}=[];
        correlation{i}=[];
        
    else
        
        for k=1:length(distance_metrics)
            if isempty(f_distance{k})
                distance_score{k}{i}=zeros(1,length(avail_ind));
                distance{k}{i}=zeros(1,length(avail_ind));
            else
                distance_score{k}{i}=f_distance{k}(distance_metrics{k}(i,avail_ind));
                distance{k}{i}=distance_metrics{k}(i,avail_ind);
            end
            
        end
        
        aligned{i}=avail_ind;
        
    end
    
    if use_corr
        avail_ind1=find(distance_links{1}(i,:)<link_pixel_distance);
        if ~single_corr
            avail_ind2=[];
            for j=1:length(avail_ind)
                avail_ind2=[avail_ind2,find(distance_links{2}(:,avail_ind(j))'<link_pixel_distance)];
            end
            link_ind=intersect(avail_ind1,avail_ind2);
        else
            link_ind=[i];
        end
        if isempty(link_ind)
            
            corr_score{i}=nan(1,length(distance_score{1}{i}));
            correlation{i}=0*ones(length(distance_score{1}{i}),2);
            
        else
            for j=1:length(avail_ind)
                
                corr_max=[0,0];
                for k=1:length(link_ind)
                    
                    score1=correlation_matrices{1}(i,link_ind(k));
                    temp=correlation_matrices{2}(link_ind(k),avail_ind(j));
                    if single_corr
                        if temp>corr_max(2)
                            corr_max=[1,temp];
                        end
                    else
                        if mean([score1,temp])>mean(corr_max)
                            corr_max=[score1,temp];
                        end
                    end
                    
                    
                end
                if single_corr
                    
                    
                    if isempty(f_corr2)
                        val=0;
                    else
                        val=f_corr2(corr_max(2));
                    end
                    
                    
                    if ~isempty(val)&mean(corr_max)>=corr_thresh
                        corr_score{i}(j)=val;
                    else
                        corr_score{i}(j)=nan;
                    end
                    
                else
                    if isempty(f_corr1)||isempty(f_corr2)
                        val=0;
                    else
                        val=(f_corr1(corr_max(1))+f_corr2(corr_max(2)))/2;
                    end
                    
                    if ~isempty(val)&mean(corr_max)>corr_thresh
                        corr_score{i}(j)=val;
                    else
                        corr_score{i}(j)=0;
                    end
                end
                correlation{i}(j,:)=corr_max;
                
            end
            
        end
    end
    
end

%Construct alignment and probability matrices
pair_aligned=[];

for i=1:size(distance_metrics{1},1)
    pair_aligned=[pair_aligned;[i*ones(length(aligned{i}),1),aligned{i}']];
   
end

for k=1:length(distance_metrics)
    distance_prob{k}=horzcat(distance_score{k}{:});
    distance_vals{k}=horzcat(distance{k}{:});
end

if use_corr==true
    correlation=vertcat(correlation{:});
    try
        corr_prob=vertcat(corr_score{:});
    catch
        corr_prob=horzcat(corr_score{:})';
    end
else
    correlation=[];
    corr_prob=[];
end


'hi';
