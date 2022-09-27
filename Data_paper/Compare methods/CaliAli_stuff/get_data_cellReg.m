function [A,C,C_raw,d]=get_data_cellReg(S,alignment_type)

%% create footprints

for i=1:size(S,2)
footprints{i}=create_sessions(0,S{1,i});
end

[~,d1,d2]=size(footprints{1,1});
d=[d1,d2];
try
[map,footprints_corrected]=align_sessions_by_cell_reg(footprints,get_distance_thr_cellReg(footprints),alignment_type);
catch
  dummy=1  
end

%% get A
for i=1:size(S,2)
    at=permute(footprints_corrected{i},[2 3 1]); a{i}=reshape(at,size(at,1)*size(at,2),[]);
end

%% get C
for i=1:size(S,2)
    load(S{1,i},'neuron');
    c{i}=neuron.C;
    cr{i}=neuron.C_raw;
end

%% sum data
for i=1:size(map,1)
t=map(i,:);
at=[];
ct=[];
crt=[];
for k=1:size(t,2)
    ix=t(k);
    if ix~=0
        at=cat(2,at,a{1, k}(:,ix));
        ct=[ct,c{1, k}(ix,:)];
        crt=[crt,cr{1, k}(ix,:)];

    else
        at=cat(2,at,a{1, k}(:,1).*nan);
        ct=[ct,c{1, k}(1,:).*0];
        crt=[crt,cr{1, k}(1,:).*0];
    end
   p(k)=mean(ct);
end
p=p./sum(p);
A(:,i)=sum(at.*p,2,'omitnan');
A(:,i)=A(:,i)./max(A(:,i));
C(i,:)=ct;
C_raw(i,:)=crt;
end

kill=sum(C,2)==0;
A(:,kill)=[];
C(kill,:)=[];
C_raw(kill,:)=[];



