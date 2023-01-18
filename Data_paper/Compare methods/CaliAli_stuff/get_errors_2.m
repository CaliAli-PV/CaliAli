function [T,Score]=get_errors_2(in,n)
detec=size(in,1);
% T=zeros(19,5);
thr=linspace(0,1,100);

S=zeros(length(thr),5);
for lo=1:length(thr)
    J=in(:,2)>thr(lo);
    TP=sum(J(:,1));
    FN=n-TP;
    FP=detec-TP;
    S(lo,2)=TP/(TP+FN);   %sensitivty or recall
    S(lo,3)=TP/(TP+FP);  %precision or PPV
    S(lo,1)=2*S(lo,3)*S(lo,2)/(S(lo,2)+S(lo,3));  %F1   
end


T=num2cell(S);
Score=T{80, 1};
T = cell2table(T,'VariableNames',{'F1','Sensitivity/recall','precision/PPV','CI','PI'});