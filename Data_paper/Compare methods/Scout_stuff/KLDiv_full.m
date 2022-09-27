function Divergences=KLDiv_full(neuron1,neuron2,overlap_matrix)
%Creates JS divergence matrix for footprints in neuron1, neuron2. Assigns 1
%if distance between centroids is larger than max_dist_construct

A1=neuron1.A;
A2=neuron2.A;
A1=A1./sum(A1,1);
A2=A2./sum(A2,1);


width1=size(A1,2);
width2=size(A2,2);
%A1=reshape(A1,neuron1.imageSize(1),neuron1.imageSize(2),[]);
%A2=reshape(A2,neuron2.imageSize(1),neuron2.imageSize(2),[]);
Divergences=ones(width1,width2);

%[a,b]=find(overlap_matrix>0);
avail_ind=find(overlap_matrix>0);
%M=(A1(:,a)+A2(:,b))/2;
%temp1=sum(A1(:,a).*(log(A1(:,a))-log(M)),1,'omitnan');
%temp2=sum(A2(:,b).*(log(A2(:,b))-log(M)),1,'omitnan');

%Divergences(avail_ind)=1/2*((sum(A1(:,a).*(log(A1(:,a))-log(M)),1,'omitnan'))+(sum(A2(:,b).*(log(A2(:,b))-log(M)),1,'omitnan')));
val=zeros(1,length(avail_ind));

parfor a=1:length(avail_ind)
    [i,j]=ind2sub([width1,width2],avail_ind(a));
    M=(A1(:,i)+A2(:,j))/2;
    log_M=log(M);
    log_M(isinf(log(M)))=0;
    log_A1=log(A1(:,i));
    log_A1(isinf(log_A1))=0;
    log_A2=log(A2(:,j));
    log_A2(isinf(log_A2))=0;
    val(a)=1/2*(sum(A1(:,i).*(log_A1-log_M))+sum(A2(:,j).*(log_A2-log_M)));
   
end
Divergences(avail_ind)=val;
Divergences=reshape(Divergences,size(A1,2),size(A2,2));
Divergences(isnan(Divergences))=max(reshape(Divergences,1,[]),[],'omitnan');