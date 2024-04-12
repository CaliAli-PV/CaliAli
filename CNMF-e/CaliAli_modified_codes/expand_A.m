function A=expand_A(A,ind_nhood,len)

for i=1:length(A)
    if ~isempty(A{i})
        I=zeros(len,1);
        I(ind_nhood{i})=A{i};
        A{i}=I;
    else
        A{i}=zeros(len,1);
    end
end

A=cat(2,A{:});