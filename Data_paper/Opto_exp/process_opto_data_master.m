function [R_sa,L,Sc_M,Active_both_sessions,C]=process_opto_data_master(T,opt)
[R_sa,L,Sc_M,Active_both_sessions]=opto_data(T,opt);
plot_heatmap(T,R_sa,opt,5,1);
plot_spatial_opto(T,opt);
C=Plot_opto(R_sa,T,opt);
end



function plot_heatmap(T,R_sa,opt,s,m) %% thr = corr threshold, m= model(e.g. 1==CaliAli, 2=CellReg, 3=SCOUT)
thr=3;
[Sc,X]=get_opto_responding(T.(m)(s,1).cr(R_sa{s,thr*10, m}(:,1)>thr,1:length(opt{1, 1})),opt{1, 1});
[~,I]=sort(mean(X(:,20:end),2),'descend');
opto_positive=X(I,:);

[Sc,X]=get_opto_responding(T.(m)(s,1).cr(R_sa{s,thr*10, m}(:,1)<=3,1:length(opt{1, 1})),opt{1, 1});
[~,I]=sort(mean(X(:,20:end),2),'descend');
opto_negative=X(I,:);

figure;tiledlayout(3,2);

nexttile([2,1]);
imagesc(opto_positive);colormap('hot');
clim([-1 25]);

nexttile([2,1]);
imagesc(opto_negative);colormap('hot');
clim([-1 25]);

op=sum(opto_positive);
op=(op-mean(op(1:20)))./std(op(1:20));

nexttile();
bar(op,'k')
ylim([-5,200])
on=sum(opto_negative);
on=(on-mean(on(1:20)))./std(on(1:20));
nexttile();
bar(on,'k')
ylim([-5,200])
end