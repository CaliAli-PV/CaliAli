function [A,C_raw]=estimate_components(Y_box,HY_box,center,sz,neuron,f)
opts=neuron.options.spatial_constraints;
A=cell(1,size(Y_box,2));
C_raw=zeros(size(Y_box,2),f);
parfor k=1:size(Y_box,2)
    try
        warning off
        if ~isempty(HY_box{k})
            [ai, ci_raw, ~] = extract_ac(HY_box{k}, Y_box{k}, center{k},sz{k},opts);
            if ~isnan(sum(ci_raw))
                A{k}=ai;
                C_raw(k,:)=ci_raw;
            else
                A{k}=[];
            end
        else
            A{k}=[];
        end
    catch
        dummy=1;
    end
end
end
