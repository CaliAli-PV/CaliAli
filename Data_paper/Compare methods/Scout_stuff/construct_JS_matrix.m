function JS_matrices=construct_JS_matrix(neurons,max_sess_dist,overlap_matrices)

%Construct JS distance between all neuron pairs extracted from
%different recordings
%inputs
%   neurons: cell array of extracted neural activity from each recording,
%       Sources2D

%outputs
%   JS_matrices: cell array of JS distance matrices
%Author: Kevin Johnston, University of California, Irvine


total=0;
clear display_progress_bar
display_progress_bar('Computing JS matrices: ',false);
num_vids=length(neurons);
JS_matrices=cell(num_vids-1,num_vids);
for i=1:(num_vids-1)*num_vids
    [a,b]=ind2sub([num_vids-1,num_vids],i);
    if b>a & (isempty(max_sess_dist)||b-a<= max_sess_dist)
        JS_matrices{i}=KLDiv_full(neurons{a},neurons{b},overlap_matrices{a,b});
        total=total+1;
        if length(neurons)<max_sess_dist
            display_progress_bar((total/((length(neurons))*(length(neurons)-1)/2)*100),false);
        end
    elseif b>a
        JS_matrices{i}=[];
        
        
    end
end

display_progress_bar(' Completed',false);
display_progress_bar('terminated',true);