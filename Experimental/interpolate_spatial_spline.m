function A=interpolate_spatial_spline(A,weights,timePoints,d)
% d=[obj.options.d1,obj.options.d2];
weights=mat2cell(weights,ones(size(weights,1),1),size(weights,2));
A=permute(reshape(A,d(1),d(2),size(A,2),size(A,3)),[3,1,2,4]);
A=num2cell(A,[2,3,4]);
A=cellfun(@(x) squeeze(x),A,'UniformOutput',false);
parfor i=1:size(A,1)
    A{i}=interpolate_a_in(A{i},d,timePoints,weights{i});
end
A=reshape(permute(cat(4,A{:}),[1,2,4,3]),d(1)*d(2),size(A,1),[]);
end

function a=interpolate_a_in(a,d,timePoints,weights)
order = 3;
knots = 3;
I=find(max(a,[],3)>0);
% Interpolate each pixel individually
for i=1:length(I)
    [row,col] = ind2sub([d(1),d(2)],I(i));
    pixelValues = squeeze(a(row,col,:));
    try
   S = std(pixelValues,full(weights))*5;
   sp0 = spaps(timePoints,pixelValues+randn(size(pixelValues))/1000,S, [],full(weights));
% sp0 = spap2(2, 2, timePoints,y,full(weights));
    extrSpline = fnxtr(sp0,1);
    a(row,col, :) = floor(fnval(extrSpline, timePoints));
    catch
        dummy=1
    a(row,col, :) = zeros(1,length(weights));
    end
end

end
