function [optimal_cell_to_index_map,spatial_footprints_corrected]=align_sessions_by_cell_reg(spatial_footprints,min_dist,alignment_type)


microns_per_pixel=1;
use_parallel_processing=true; % either true or false
maximal_rotation=30; % in degrees - only relevant if 'Translations and Rotations' is used
transformation_smoothness=2; % levels of non-rigid FOV transformation smoothness (range 0.5-3)
reference_session_index=1;

 [normalized_spatial_footprints]=normalize_spatial_footprints(spatial_footprints);
% normalized_spatial_footprints=spatial_footprints;
[adjusted_spatial_footprints,adjusted_FOV,~,~,~]=...
    adjust_FOV_size(normalized_spatial_footprints);
[adjusted_footprints_projections]=compute_footprints_projections(adjusted_spatial_footprints);
[centroid_locations]=compute_centroid_locations(adjusted_spatial_footprints,microns_per_pixel);
[centroid_projections]=compute_centroids_projections(centroid_locations,adjusted_spatial_footprints);

% Aligning the cells according to the tranlations/rotations that maximize their similarity:
sufficient_correlation_centroids=0.2; % smaller correlation imply no similarity between sessions
sufficient_correlation_footprints=0.2; % smaller correlation imply no similarity between sessions
if strcmp(alignment_type,'Translations and Rotations')
    [spatial_footprints_corrected,centroid_locations_corrected,~,~,~,~,~]=...
        align_images(adjusted_spatial_footprints,centroid_locations,adjusted_footprints_projections,centroid_projections,adjusted_FOV,microns_per_pixel,reference_session_index,alignment_type,sufficient_correlation_centroids,sufficient_correlation_footprints,use_parallel_processing,maximal_rotation);
elseif strcmp(alignment_type,'Non-rigid')
    [spatial_footprints_corrected,centroid_locations_corrected,~,~,~,~,~,~]=...
        align_images(adjusted_spatial_footprints,centroid_locations,adjusted_footprints_projections,centroid_projections,adjusted_FOV,microns_per_pixel,reference_session_index,alignment_type,sufficient_correlation_centroids,sufficient_correlation_footprints,use_parallel_processing,transformation_smoothness);
else
    [spatial_footprints_corrected,centroid_locations_corrected,~,~,~,~,~]=...
        align_images(adjusted_spatial_footprints,centroid_locations,adjusted_footprints_projections,centroid_projections,adjusted_FOV,microns_per_pixel,reference_session_index,alignment_type,sufficient_correlation_centroids,sufficient_correlation_footprints,use_parallel_processing);
end

maximal_distance=min_dist; % cell-pairs that are more than 12 micrometers apart are assumed to be different cells
normalized_maximal_distance=maximal_distance/microns_per_pixel;

[~,centers_of_bins]=estimate_number_of_bins(spatial_footprints,normalized_maximal_distance);
[all_to_all_indexes,all_to_all_spatial_correlations,all_to_all_centroid_distances,neighbors_spatial_correlations,neighbors_centroid_distances,~,~,~,~,~,~]=...
    compute_data_distribution(spatial_footprints_corrected,centroid_locations_corrected,normalized_maximal_distance);

[~,p_same_given_centroid_distance,~,centroid_distances_model_same_cells,centroid_distances_model_different_cells,~,MSE_centroid_distances_model,centroid_distance_intersection]=...
    compute_centroid_distances_model(neighbors_centroid_distances,microns_per_pixel,centers_of_bins);

[~,p_same_given_spatial_correlation,~,spatial_correlations_model_same_cells,spatial_correlations_model_different_cells,~,MSE_spatial_correlations_model,spatial_correlation_intersection]=...
    compute_spatial_correlations_model(neighbors_spatial_correlations,centers_of_bins);

[best_model_string]=choose_best_model(MSE_centroid_distances_model,centroid_distances_model_same_cells,centroid_distances_model_different_cells,p_same_given_centroid_distance,MSE_spatial_correlations_model,spatial_correlations_model_same_cells,spatial_correlations_model_different_cells,p_same_given_spatial_correlation);

[all_to_all_p_same_centroid_distance_model,all_to_all_p_same_spatial_correlation_model]=...
    compute_p_same(all_to_all_centroid_distances,p_same_given_centroid_distance,centers_of_bins,all_to_all_spatial_correlations,p_same_given_spatial_correlation);

initial_registration_type=best_model_string; % either 'Spatial correlation', 'Centroid distance', or 'best_model_string';


if strcmp(initial_registration_type,'Spatial correlation') % if spatial correlations are used
    if exist('spatial_correlation_intersection','var')
        initial_threshold=spatial_correlation_intersection; % the threshold for p_same=0.5;
    else
        initial_threshold=0.65; % a fixed correlation threshold not based on the model
    end
    [cell_to_index_map,~,~]=...
        initial_registration_spatial_correlations(normalized_maximal_distance,initial_threshold,spatial_footprints_corrected,centroid_locations_corrected);
else % if centroid distances are used
    if exist('centroid_distance_intersection','var')
        initial_threshold=centroid_distance_intersection; % the threshold for p_same=0.5;
    else
        initial_threshold=5; % a fixed distance threshold not based on the model
    end
    normalized_distance_threshold=initial_threshold/microns_per_pixel;
    [cell_to_index_map,~,~]=...
        initial_registration_centroid_distances(normalized_maximal_distance,normalized_distance_threshold,centroid_locations_corrected);
end

registration_approach='Probabilistic'; % either 'Probabilistic' or 'Simple threshold'
model_type=best_model_string; % either 'Spatial correlation' or 'Centroid distance'
p_same_threshold=0.5; % only relevant if probabilistic approach is used

% Deciding on the registration threshold:
transform_data=false;
if strcmp(registration_approach,'Simple threshold') % only relevant if a simple threshold is used
    if strcmp(model_type,'Spatial correlation')
        if exist('spatial_correlation_intersection','var')
            final_threshold=spatial_correlation_intersection; % the threshold for p_same=0.5;
        else
            final_threshold=0.65; % a fixed correlation threshold not based on the model
        end
    elseif strcmp(model_type,'Centroid distance')
        if exist('centroid_distance_intersection','var')
            final_threshold=centroid_distance_intersection; % the threshold for p_same=0.5;
        else
            final_threshold=5; % a fixed distance threshold not based on the model
        end
        normalized_distance_threshold=(maximal_distance-final_threshold)/maximal_distance;
        transform_data=true;
    end
else
    final_threshold=p_same_threshold;
end

% Registering the cells with the clustering algorithm:
% disp('Stage 5 - Performing final registration')
if strcmp(registration_approach,'Probabilistic')
    if strcmp(model_type,'Spatial correlation')
        [optimal_cell_to_index_map,registered_cells_centroids,cell_scores,cell_scores_positive,cell_scores_negative,cell_scores_exclusive,p_same_registered_pairs]=...
            cluster_cells(cell_to_index_map,all_to_all_p_same_spatial_correlation_model,all_to_all_indexes,normalized_maximal_distance,p_same_threshold,centroid_locations_corrected,registration_approach,transform_data);
    elseif strcmp(model_type,'Centroid distance')
        [optimal_cell_to_index_map,registered_cells_centroids,cell_scores,cell_scores_positive,cell_scores_negative,cell_scores_exclusive,p_same_registered_pairs]=...
            cluster_cells(cell_to_index_map,all_to_all_p_same_centroid_distance_model,all_to_all_indexes,normalized_maximal_distance,p_same_threshold,centroid_locations_corrected,registration_approach,transform_data);
    end
%     plot_cell_scores(cell_scores_positive,cell_scores_negative,cell_scores_exclusive,cell_scores,p_same_registered_pairs,[],1)
elseif strcmp(registration_approach,'Simple threshold')
    if strcmp(model_type,'Spatial correlation')
        [optimal_cell_to_index_map,registered_cells_centroids]=...
            cluster_cells(cell_to_index_map,all_to_all_spatial_correlations,all_to_all_indexes,normalized_maximal_distance,final_threshold,centroid_locations_corrected,registration_approach,transform_data);
    elseif strcmp(model_type,'Centroid distance')
        [optimal_cell_to_index_map,registered_cells_centroids]=...
            cluster_cells(cell_to_index_map,all_to_all_centroid_distances,all_to_all_indexes,normalized_maximal_distance,normalized_distance_threshold,centroid_locations_corrected,registration_approach,transform_data);
    end
end
% plot_all_registered_projections(spatial_footprints_corrected,cell_to_index_map,[],1)
disp([num2str(size(optimal_cell_to_index_map,1)) ' cells were found'])
close all

