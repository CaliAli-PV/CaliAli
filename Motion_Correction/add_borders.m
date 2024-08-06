function Vout=add_borders(Mr,mask)

[d1,d2]=size(mask);
[od1,od2,d3]=size(Mr);
Vout=zeros(d1*d2,d3,'uint8');

Vout(mask(:),:)=reshape(Mr,od1*od2,[]);

Vout=reshape(Vout,d1,d2,d3);