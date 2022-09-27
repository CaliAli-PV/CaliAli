function [footprints_projections]=compute_footprints_projections(spatial_footprints)
% This function gets the spatial footprints of all the cells from all
% sessions and computes their projections on the FOV.

% Inputs: 
% 1. spatial_footprints - cell array with spatial footprints from all sessions

% Outputs: 
% 1. footprints_projections - cell array with the projection of all spatial 
% footprints onto the same FOV (separately for any given session) 

pixel_weight_threshold=0.5; % for better visualization of cells
number_of_sessions=size(spatial_footprints,2);
footprints_projections=cell(1,number_of_sessions);
disp('Calculating spatial footprints projections:')
for n=1:number_of_sessions
    display_progress_bar('Terminating previous progress bars',true)
    display_progress_bar(['Calculating footprints projections for session #' num2str(n) ' - '],false)
    this_session_spatial_footprints=spatial_footprints{n};

    temp_spatial_footprint_max= max(max(this_session_spatial_footprints,[],2),[],3);
    normalized_spatial_footprints = ...
        this_session_spatial_footprints ./ temp_spatial_footprint_max;
    normalized_spatial_footprints(normalized_spatial_footprints<pixel_weight_threshold)=0;

    footprints_projections{n}=squeeze(sum(normalized_spatial_footprints,1));
    display_progress_bar(' done',false);
end

end