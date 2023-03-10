function [neurons,links]=align_scout_PV(neurons,links);

for i=1:size(neurons,2)
footprints{i}=permute(reshape(neurons{1, i}.A,neurons{1, i}.options.d1 ...
    ,neurons{1, i}.options.d2,size(neurons{1, i}.A,2)),[3 1 2]);
end

k=size(footprints,2);
for i=1:size(links,2)
footprints{i+k}=permute(reshape(links{1, i}.A,links{1, i}.options.d1 ...
    ,links{1, i}.options.d2,size(links{1, i}.A,2)),[3 1 2]);
end

microns_per_pixel=1;
[normalized_spatial_footprints]=normalize_spatial_footprints(footprints);
% normalized_spatial_footprints=spatial_footprints;
[adjusted_spatial_footprints,adjusted_FOV,~,~,~]=...
    adjust_FOV_size(normalized_spatial_footprints);
[adjusted_footprints_projections]=compute_footprints_projections(adjusted_spatial_footprints);
[centroid_locations]=compute_centroid_locations(adjusted_spatial_footprints,microns_per_pixel);
[centroid_projections]=compute_centroids_projections(centroid_locations,adjusted_spatial_footprints);

[footprints_corrected,c,fp]=align_images(adjusted_spatial_footprints,centroid_locations, ...
    adjusted_footprints_projections,centroid_projections, ...
    adjusted_FOV,1,1,'Non-rigid',0.2,0.2,1,2);


for i=1:size(neurons,2)
    neurons{1, i}.A=reshape(permute(footprints_corrected{i},[2 3 1]), ...
        neurons{1, i}.options.d1*neurons{1, i}.options.d2,[]);
end

for i=1:size(links,2)
    links{1, i}.A=reshape(permute(footprints_corrected{i+k},[2 3 1]), ...
        links{1, i}.options.d1*links{1, i}.options.d2,[]);
end


