function [T,Mask]=square_borders(in,nanval,valid)
%% Crop to the largest rectangle that is valid in every frame.
%
% VALID (optional) is a logical mask, true where a pixel holds real data. Supply
% it and the invalid region is known rather than inferred.
%
% Without it, invalidity is inferred from the pixel VALUE -- either NaN, or
% equal to NANVAL. That is why the pipeline used to add 1 to the whole
% recording: so 0 could only mean "filled by a translation". The inference is
% wrong whenever the data genuinely contains that value, and after detrending
% with force_non_negative it always does. Rigid_mc now returns the mask
% directly; the value test remains for data that arrives without one, such as
% files written by an earlier version.

[d1,d2,d3]=size(in);
T=zeros(d1+2,d2+2,d3,class(in))*nan;
T(2:d1+1,2:d2+1,:)=in;
clear in
if exist('valid','var') && ~isempty(valid)
    % The border ring stays invalid: FindLargestRectangles returns a degenerate
    % one-pixel strip when handed a mask with no invalid pixel at all.
    N = true(d1+2, d2+2);
    N(2:d1+1, 2:d2+1) = ~all(valid, 3);
    T(isnan(T)) = 0;
elseif ~exist('nanval','var')
N=sum(isnan(T),3)>0;
else
  T(isnan(T))=nanval; 
 N=max(T==nanval,[],3);      
end

[~,~, ~, M] = FindLargestRectangles(1-N);

M=M(2:end-1,2:end-1);
Mask=M;
T([1,end],:,:)=[];T(:,[1,end],:)=[];

T=reshape(T,(d1)*(d2),[]);
M=reshape(M,(d1)*(d2),1);
T(~M,:)=0;
T=reshape(T,d1,d2,[]);