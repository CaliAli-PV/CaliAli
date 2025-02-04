function active_pixels = active_contour_grow(neuron)

A=neuron.A;
Cn=neuron.CaliAli_options.inter_session_alignment.Cn;
d=[neuron.options.d1,neuron.options.d2];
Cn(Cn<neuron.CaliAli_options.cnmf.dendrite_initialization_threshold)=0;

Cn=double(Cn);
active_pixels=zeros(d(1),d(2),size(A,2));
% parfor i=1:size(A,2)
%     mask=reshape(full(A(:,i)),d)>0;
%     active_pixels(:,:,i) = activecontour(Cn,mask,'Chan-Vese','ContractionBias',-0.2);
% end
A=A./max(A);
se = strel("disk",3);
parfor i=1:size(A,2)
    mask=reshape(full(A(:,i)),d)>0.01;
    active_pixels(:,:,i)=imdilate(mask,se);
end

active_pixels=reshape(active_pixels,d(1)*d(2),[]);