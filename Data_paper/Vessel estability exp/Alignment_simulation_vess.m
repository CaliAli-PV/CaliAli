function [Score,err,dist,Vsim]=Alignment_simulation_vess(rep,flist)
% [Score,err,dist,Vsim]=Alignment_simulation_vess(1,'multi_session_par.xlsx');
% [Score,err,dist,Vsim]=Alignment_simulation_vess(1,'vessel_combine.xlsx');
if ~exist('rep','var')
    rep = 1;
end

Ce = table2cell(readtable(flist,'Format','auto','ReadVariableNames', false));
k=1;
for i=1:size(Ce,1)
    for r=1:rep
    fprintf(1, 'Simulating alignment #%g out of %g...\n', k,size(Ce,1)*rep);
    [Score(k,:),err(k,:),dist(:,:,:,k),Vsim(k,:)]=compare_alignment_methods_vessel(Ce(i,:));
    k=k+1;
    end
end

for i=1:size(dist,3)
    C{i,1}=squeeze(dist(:,:,i,:));
end

nam={'Corr';'Vesselness';'Vess.+ Corr.'};

dist=cell2table(C,'VariableNames',{'Sims'},'RowNames',nam);




%{

dist.Sims{3,1};
d=squeeze(ans(5,:,:));

d=dist.Sims{1,1};
d=squeeze(d(2,:,:));
d=reshape(d,1000,11,7);
d=squeeze(d(800,:,:));
%}






