function labeled = segment_branches(img, min_branch_length)
%SEGMENT_BRANCHES Segments branches in a binary image, with length control.
%   labeled = SEGMENT_BRANCHES(img, min_branch_length) takes a binary image 'img' 
%   and the minimum desired branch length 'min_branch_length' as input. It returns 
%   a labeled image where each branch is assigned a different label.

% 1. Skeletonization
img_skel = bwmorph(img, 'skel', Inf);

% 2. Identify Branch Points
branchpoints = bwmorph(img_skel, 'branchpoints');

% 3. Separate Branches
img_segmented = img_skel;  
CC = bwconncomp(img_segmented); 

while nnz(branchpoints) > 0 
    img_segmented(branchpoints) = 0; 
    CC_new = bwconncomp(img_segmented); 

    % Check if new components meet the length criterion
    if CC_new.NumObjects > CC.NumObjects
        valid_branches = true(CC_new.NumObjects, 1);
        for k = 1:CC_new.NumObjects
            branch_length = numel(CC_new.PixelIdxList{k});
            if branch_length < min_branch_length
                valid_branches(k) = false;
            end
        end

        % Accept the split only if all new branches meet the length criterion
        if all(valid_branches)
            CC = CC_new;
        else
            img_segmented(branchpoints) = 1; % Revert the removal
        end
    end

    branchpoints = bwmorph(img_segmented, 'branchpoints'); 
end

% Label connected components
labeled = labelmatrix(CC);

end