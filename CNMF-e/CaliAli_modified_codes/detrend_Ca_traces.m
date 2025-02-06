function out=detrend_Ca_traces(nums,obj,F)
%% detrend_Ca_traces: Removes slow baseline fluctuations from calcium traces.
%
% Inputs:
%   nums - The window size factor used for median filtering and erosion.
%   obj  - The calcium activity traces (matrix of size [neurons x frames]).
%   F    - (Optional) The number of frames per batch. Defaults to `size(obj,2)`.
%
% Outputs:
%   out  - The detrended calcium traces with baseline fluctuations removed.
%
% Usage:
%   out = detrend_Ca_traces(nums, obj);
%   out = detrend_Ca_traces(nums, obj, F);
%
% Description:
%   - This function removes slow baseline trends from calcium traces.
%   - It applies a median filter (`medfilt1`) to smooth the signal over `nums*10` frames.
%   - The baseline is further refined using morphological erosion (`imerode`).
%   - Detrended traces are obtained by subtracting the estimated baseline from the original signal.
%   - If the dataset is processed in batches, results are concatenated accordingly.
%
% Features:
%   - Uses parallel computing (`parfor`) for efficiency.
%   - Handles multi-batch datasets by processing each segment separately.
%   - Reduces slow baseline fluctuations while preserving transient activity.
%
% Notes:
%   - ⚠ WARNING: Running this function modifies the temporal traces in a way that makes them unsuitable for 
%     further CNMF iterations. If additional CNMF iterations are needed, `update_temporal_CaliAli` must be 
%     rerun to restore a compatible state.
%   - Useful for improving calcium imaging signal clarity before further analysis.
%   - Helps in detecting spike activity more accurately by removing slow drift artifacts.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025


if ~exist('F','var')
    F=size(obj,2);
end

obj=double(obj);
BL=obj;
k=0;
for j=1:size(F,2)
    x=obj(:,k+1:k+F(j));
    out=[];
    parfor i=1:size(obj,1)
        temp=medfilt1(x(i,:),nums*10,'truncate');
        bl=imerode(temp', ones(nums*50, 1))';
        %     bl(bl>0)=0;
        %     plot(neuron.C_raw(i,:));hold on;plot(temp);plot(bl);
        % BL(i,:)=bl;
        out(i,:)=x(i,:)-bl;
    end
    Oc{j}=out;
    k=k+F(j);
end

out=cat(2,Oc{:});