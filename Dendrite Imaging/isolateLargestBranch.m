function mainBranch = isolateLargestBranch(img)
% Isolates the largest branch in a skeletonized image.
% Input:
%   img: Binary image of the object.
% Output:
%   mainBranch: Binary image containing only the largest branch.

skeleton = bwskel(img);                 % Skeletonize the input image.
branchpoints = bwmorph(skeleton, 'branchpoints'); % Find branchpoints.
skeleton(branchpoints)=0;                % Remove branchpoints to segment the skeleton.
labeled_skeleton = bwlabel(skeleton);    % Label connected components (branches).
stats = regionprops(skeleton, 'Area');  % Calculate area of each branch.
[~,I]=max([stats.Area]);               % Find the index of the largest branch.
se = strel('disk', 1);                  % Create a disk structuring element for dilation.
for i=1:10                             % Dilate 10 times to reconstruct the shape.
    labeled_skeleton=dilate_components(labeled_skeleton,se,img); % Dilate branches, constrained by the original image.
end
mainBranch=labeled_skeleton==I;         % Extract the largest branch.
end

function out=dilate_components(labeled_skeleton,se,img)
% Dilates each labeled component, constrained by an original image.
% Inputs:
%   labeled_skeleton: Image with labeled components.
%   se: Structuring element for dilation.
%   img: Original binary image for constraint.
% Output:
%   out: Image with dilated components.

out=labeled_skeleton*0; % Initialize output.
[d1,d2]=size(labeled_skeleton);
temp=zeros(d1,d2,max(labeled_skeleton,[],'all'));
for i=1:max(labeled_skeleton,[],'all') % Iterate through each labeled component.
    temp(:,:,i)=imdilate(labeled_skeleton==i,se).*img; % Dilate each component, constrained by the original image.
end
[r,c]=ind2sub(size(labeled_skeleton),find(sum(temp,3)>1)); % Find overlapping pixels.
temp(r,c,:)=0; % Remove overlaps.
for i=1:size(temp,3) % Recombine dilated components.
    out=out+temp(:,:,i)*i;
end
end