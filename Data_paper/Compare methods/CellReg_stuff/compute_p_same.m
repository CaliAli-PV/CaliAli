function [all_to_all_p_same_centroid_distance_model,varargout]=compute_p_same(all_to_all_centroid_distances,p_same_given_centroid_distance,centers_of_bins,varargin)
% This function computes and saves in a data structure the p(same) 
% for all neighboring cells pairs across sessions according to the
% different models

% Inputs:
% 1. all_to_all_centroid_distances
% 2. p_same_given_centroid_distance
% 3. centers_of_bins
% 4. varargin
%   4{1}. all_to_all_spatial_correlations
%   4{2}. p_same_given_spatial_correlation

% Outputs:
% 1. all_to_all_p_same_centroid_distance_model
% 2. varargout
%   2{1} all_to_all_p_same_spatial_correlation_model

number_of_sessions=size(all_to_all_centroid_distances,2);

% defining output variables:

all_to_all_spatial_correlations=varargin{1};
p_same_given_spatial_correlation=varargin{2};
all_to_all_p_same_spatial_correlation_model=cell(1,number_of_sessions);
all_to_all_p_same_centroid_distance_model=cell(1,number_of_sessions);

% computing P_Same:
for n=1:number_of_sessions
    number_of_cells=size(all_to_all_centroid_distances{n},1);   
    all_to_all_p_same_spatial_correlation_model{n}=cell(number_of_cells,number_of_sessions);
    
    all_to_all_p_same_centroid_distance_model{n}=cell(number_of_cells,number_of_sessions);    
    sessions_to_compare=1:number_of_sessions;
    sessions_to_compare(n)=[];
    for k=1:number_of_cells % for each cell
        for m=1:length(sessions_to_compare)
            this_session=sessions_to_compare(m);
            temp_corr_vec=all_to_all_spatial_correlations{n}{k,this_session};
            temp_dist_vec=all_to_all_centroid_distances{n}{k,this_session};
            length_vec=length(temp_dist_vec);
            if length_vec>0
                p_same_given_spatial_correlation_vec=zeros(1,length(temp_corr_vec));
                p_same_given_centroid_distance_vec=zeros(1,length(temp_dist_vec));
                for p=1:length_vec
                    [~,this_corr_ind]=min(abs(centers_of_bins{2}-temp_corr_vec(p)));
                    this_p_same_given_spatial_correlation=p_same_given_spatial_correlation(this_corr_ind);
                    p_same_given_spatial_correlation_vec(p)=this_p_same_given_spatial_correlation;
                    [~,this_dist_ind]=min(abs(centers_of_bins{1}-temp_dist_vec(p)));
                    this_p_same_given_centroid_distance=p_same_given_centroid_distance(this_dist_ind);
                    p_same_given_centroid_distance_vec(p)=this_p_same_given_centroid_distance;
                end
                all_to_all_p_same_spatial_correlation_model{n}{k,this_session}=p_same_given_spatial_correlation_vec;
                all_to_all_p_same_centroid_distance_model{n}{k,this_session}=p_same_given_centroid_distance_vec;
            end
        end
    end
end

varargout{1}=all_to_all_p_same_spatial_correlation_model;

end

