function [aligned_neurons,aligned_probabilities,reg_prob]=construct_tracking_matrices_kmedoids(aligned,probabilities,...
    min_prob,chain_prob,dist_vals,max_sess_dist,size_vec,method,penalty,max_gap,max_pixel_dist,distance_metrics,centroids,reconstitute,prob)


disp('Tracking Using Spatial Criterion')

[aligned_neurons,reg_prob,aligned_probabilities]=construct_aligned_neuron_graph_kmedoids(aligned,...
            probabilities,size_vec,chain_prob,prob,dist_vals,min_prob,max_gap);

%aligned_probabilities=construct_combined_probabilities_adj(aligned_neurons,probabilities,aligned,dist_vals,min_prob,[],[],max_sess_dist);
