function C=Plot_opto(R_sa,T,opt)
%% 5,6,6 are representative recordings 
s=[5,6,6];
figure;tiledlayout(1,6);
for m=1:3
    nexttile;
c_t=T.(m)(s(m),1).cr;
thr=3;

or=sum(R_sa{s(m),thr*10, m}>thr,2)>0; % opto responding in at least one session
c_t(~or,:)=[];
Rt=R_sa{s(m),thr*10,m}(or,:);

rt=prod(Rt>thr,2);
rt(rt~=1)=-1;
rt=rt.*max(Rt,[],2);


P=sum(Rt>thr,2)==2;

[rt,I]=sort(rt,'descend');
P=P(I);
Rt=Rt(I,:);
c_t=c_t(I,:);

% Ls=10;
% 
% ix=round(linspace(1,size(I,1),Ls));


c_t=c_t([1:8,size(I,1)-7:size(I,1)],:);
Ls=size(c_t,1);

c_t=(c_t./GetSn(c_t));

%%================
c1=c_t(:,1:size(opt{1, 1},1));

[X]=get_mean_trace(c1,opt{1, 1})+((0:-1:-Ls+1).*10-10)';

plot(X','DisplayName','X');ylim([-110 10])

c2=c_t(:,size(opt{1, 1},1)+1:end);

[X]=get_mean_trace(c2,opt{1, 2})+((0:-1:-Ls+1).*10-10)';

nexttile;

plot(X','DisplayName','X');ylim([-110 10])

C{m}=[c1,c2]'+((0:-1:-Ls+1).*40-40);
end
















