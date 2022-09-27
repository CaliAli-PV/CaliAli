function [A,C_raw]=estimate_components(Y_box,HY_box,center,sz,opts)

A=cell(1,size(Y_box,2));
C_raw=zeros(size(Y_box,2),size(Y_box{1,1},2));
parfor k=1:size(Y_box,2)
warning off
[ai, ci_raw, ~] = extract_ac(HY_box{k}, Y_box{k}, center{k},sz{k},opts);
A{k}=ai;
C_raw(k,:)=ci_raw;
end

