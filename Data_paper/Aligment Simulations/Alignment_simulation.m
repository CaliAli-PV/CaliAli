function [Score,err,T]=Alignment_simulation(rep)
% [Score,err,dist]=Alignment_simulation(5);
if ~exist('rep','var')
    rep = 1;
end

Ce = table2cell(readtable('par_alignment.xlsx','Format','auto','ReadVariableNames', false));
k=1;
for i=1:size(Ce,1)
    for r=1:rep
    fprintf(1, 'Simulating alignment #%g out of %g...\n', k,size(Ce,1)*rep);
    [Score(k,:),err(k,:),dist(:,:,k)]=compare_alignment_methods(Ce(i,:));
    k=k+1;
    end
end


nam={'mean';'Gauss';'Corr.';'CaliAli_old';'CaliAli'};

dist=permute(dist,[2,1,3]);

Nv=size(dist,3)./(8*rep);

C={};
for i=1:size(dist,1)
    temp=squeeze(dist(i,:,:));
    C=cat(1,C,mat2cell(temp,1000,[repelem(8*rep,Nv)]));
end

T=cell2table(C,'VariableNames', ...
    {'ideal','Remapping','Sparse','Remapping+Sparse','Dense'},'RowNames',nam);





