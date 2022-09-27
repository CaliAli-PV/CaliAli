function [aligned_neurons,aligned_probabilities]=Eliminate_Duplicates(aligned_neurons,aligned_probabilities)
%Eliminate duplicate chains
% aligned_neurons: matrix of neuron chains
% aligned_probabilities: matrix of chain member probabilities


[aligned_neurons,id1,id2]=unique(aligned_neurons,'rows');

aligned_probabilities=aligned_probabilities(id1,:);
