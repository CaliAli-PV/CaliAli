function [Mask,F]=get_mask_and_F(theFiles)
fprintf(1, 'Obtaining registration borders and number of frames...\n');
for i=progress(1:size(theFiles,2))
    fullFileName = theFiles{i};
    Vid=h5read(fullFileName,'/Object');
    F(i)=size(Vid,3);
    [~,Mask(:,:,i)]=remove_borders(Vid,0);
end

%% remove borders
Mask=min(Mask,[],3);
% [~,Mask]=remove_borders(double(Mask),0);
end