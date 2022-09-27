function A=expand_A(A,ind_nhood,len)

for i=1:length(A)
    I=zeros(len,1);
    I(ind_nhood{i})=A{i};
    A{i}=I;
end
A=cat(2,A{:});