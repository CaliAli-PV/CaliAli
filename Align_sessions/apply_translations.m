function [Vid,P2]=apply_translations(Vid,P)

[P2,T,Mask]=sessions_translate(P);
[d1,d2,~]=size(Mask);
f1=max(sum(Mask,1));
f2=max(sum(Mask,2));
    for i=1:length(Vid)
            temp=imtranslate(Vid{i},T(i,:));
            temp=reshape(temp,d1*d2,[]);
            temp=temp(Mask,:);
            Vid{i}=reshape(temp,f1,f2,[]);
    end
    
end
