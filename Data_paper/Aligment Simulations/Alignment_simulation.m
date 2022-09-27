function [Score,err,dist]=Alignment_simulation(rep)
% [Score,err,dist]=Alignment_simulation(1);
if ~exist('rep','var')
    rep = 1;
end

Ce = table2cell(readtable('par_alignment.xlsx','Format','auto','ReadVariableNames', false));
k=1;
for i=1:size(Ce,1)
    for r=1:rep
    fprintf(1, 'Simulating alignment #%g out of %g...\n', k,size(Ce,1)*rep);
    [Score(k,:),err(k,:),dist(:,:,:,k)]=compare_alignment_methods(Ce(i,:));
    k=k+1;
    end
end


for i=1:size(dist,3)
    C{i,1}=squeeze(dist(:,:,i,:));
end

nam={'mean';'Gauss';'Corr.';'Vesselness';'Vess.+ Corr.'};


dist=cell2table(C,'VariableNames',{'Sims'},'RowNames',nam);





