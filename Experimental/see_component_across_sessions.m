function out=see_component_across_sessions(obj,crit)
% out=see_component_across_sessions(neuron,neuron.Unstable_components);
for i=1:size(obj.A_batch,2)
    temp=get_cell_square(squeeze(obj.A_batch(:,i,:)),[obj.options.d1,obj.options.d2],[25 25]);
    T(:,:,i,:)=temp;
end

for i=1:size(T,4)
    temp=mat2gray(T(:,:,:,i));
    temp=repmat(reshape(temp,25,25,1,[]),1,1,3,1);
    temp(:,:,2:3,crit)=0;
    temp(:,:,[1,3],~crit)=0;
    out(:,:,:,i)=imtile(temp);
end

end


function  out=get_cell_square(A,d,sz)

sz=floor(sz./2);
A=reshape(A,d(1),d(2),[]);
im=max(A,[],3);
[~,I]=max(im,[],'all');
[row,col]=ind2sub([d(1),d(2)],I);

r1=max([row-sz(1),1]);
r2=min([row+sz(1),d(1)]);

c1=max([col-sz(2),1]);
c2=min([col+sz(2),d(2)]);

out=catpad(3,zeros(sz(1),sz(2)),A(r1:r2,c1:c2,:));
out(:,:,1)=[];
end

