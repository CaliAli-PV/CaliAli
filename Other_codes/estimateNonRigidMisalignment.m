function out = estimateNonRigidMisalignment(fixedGray, movingGray)
% Ensure that images are 2D matrices
if ndims(fixedGray) ~= 2 || ndims(movingGray) ~= 2
    error('Input images must be 2D matrices.');
end

fixedGray=mat2gray(fixedGray);
movingGray=mat2gray(movingGray);
% Detect SURF features in both images
pointsFixed = get_seeds_in(fixedGray);
pointsMoving = get_seeds_in(movingGray);

% Extract features from both images
[featuresFixed, validPointsFixed] = extractFeatures(fixedGray, pointsFixed,"Method","SURF");
[featuresMoving, validPointsMoving] = extractFeatures(movingGray, pointsMoving,"Method","SURF");

% 
% figure;
%     imshow(fixedGray); hold on;
%     plot(validPointsFixed);
%     title('Extracted Features in Fixed Image');
% 
%     figure;
%     imshow(movingGray); hold on;
%     plot(validPointsMoving);
%     title('Extracted Features in Moving Image');

% Match features between the images
[indexPairs,metric] = matchFeatures(featuresFixed, featuresMoving,"MatchThreshold",100,"MaxRatio",1);


% Retrieve matched points
matchedPointsFixed = validPointsFixed(indexPairs(:, 1));
matchedPointsMoving = validPointsMoving(indexPairs(:, 2));

I=sqrt(sum((matchedPointsFixed.Location-matchedPointsMoving.Location).^2,2));
ix=I>20;
I(I>20)=[];
out=mean(I);


% 
% indexPairs(ix,:)=[];
% matchedPointsFixed = validPointsFixed(indexPairs(:, 1));
% matchedPointsMoving = validPointsMoving(indexPairs(:, 2));
% 
% figure;
% showMatchedFeatures(fixedGray, movingGray, matchedPointsFixed, matchedPointsMoving);
% title('Matched SURF Points');


end




function out=get_seeds_in(in)
tmp_d = max(1,round(2.5));
v_max = ordfilt2(in, tmp_d^2, true(tmp_d));
ind = (v_max==in);
ind(in<0.1)=0;
[r1, c1] = find(ind); out= [c1, r1] ;
end