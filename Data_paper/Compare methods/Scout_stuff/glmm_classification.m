
function [w,mu,sigma,error]=glmm_classification(X)
%creates parameters for gaussian-lognormal mixture model using data X
        %
        X=X-min(X);
        minim=min(X)-.001;
        maxim=max(X)+max(abs(X));
        minim=min(X)-max(abs(X));


warning('off','all')
bw=optimal_bandwidth(X);
[f,x1,bw]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Bandwdith',bw);
modelfun=@(b,x) b(1)*lognpdf(x,b(2),b(3))+(1-b(1))*normpdf(x,b(4),b(5));
ind=find(f>.0001*max(f));
model_min=min(x1(ind));
model_max=max(x1(ind));


mu=[];
Sigma=[];
w=[];
iter=1;
max_iter=10;
while isempty(mu)&iter<=max_iter
    bw=bw*iter;
try
    warning('');
beta=nlinfit(x1,f,modelfun,[.5,-2,.5,model_max,.1]);
[warnMsg,warnId]=lastwarn;
if isempty(warnMsg)
mu=[mu;[beta(2),beta(4)]];
Sigma=[Sigma;[beta(3),beta(5)]];
w=[w;[beta(1),1-beta(1)]];
end
end
for i=2:100
try
warning('');
init_beta=[unifrnd(.1,.9),unifrnd(-5,1),unifrnd(.01,1),unifrnd(model_min,model_max),unifrnd(.01,1)];
opts=statset('MaxIter',300);
beta=nlinfit(x1,f,modelfun,init_beta,opts);
[warnMsg,warnId]=lastwarn;
if isempty(warnMsg)
mu=[mu;[beta(2),beta(4)]];
Sigma=[Sigma;[beta(3),beta(5)]];
w=[w;[beta(1),1-beta(1)]];
end
end
end
if isempty(mu)
    iter=iter+1;
    [f,x1,bw]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Bandwidth',bw);
end
end
warning('on','all')
ind_del=find(sum(isnan(w),2)>0|min(w,[],2)<0|max(w,[],2)>1);
w(ind_del,:)=[];
mu(ind_del,:)=[];
Sigma(ind_del,:)=[];

% [mu,ind]=sort(mu,2);
% ind=reshape(ind,1,[]);
% first_col=find(ind==1);
% Sigma=reshape(Sigma,1,[]);
% Sigma=[Sigma(first_col)',Sigma(setdiff(1:length(Sigma),first_col))'];
% w=reshape(w,1,[]);
% w=[w(first_col)',w(setdiff(1:length(w),first_col))'];



w=round(w,4);
Sigma=round(Sigma,4);
mu=round(mu,4);
mode_weight_w=mode(w,1);

mode_weight_S=mode(Sigma,1);

mode_weight_mu=mode(mu,1);

ind_del=find(abs(sum(w-mode_weight_w,2))>10^(-3)|abs(sum(Sigma-mode_weight_S,2))>10^(-3)|abs(sum(mu-mode_weight_mu,2))>10^(-3));


w(ind_del,:)=[];
mu(ind_del,:)=[];
Sigma(ind_del,:)=[];

w=trimmean(w,10,1);
mu=trimmean(mu,10,1);
sigma=trimmean(Sigma,10,1);
w=w/sum(w);

del_ind=find(x1<min(X)|x1>max(X));
x1(del_ind)=[];
f(del_ind)=[];


f1=@(x) w(1)*lognpdf(x,mu(1),sigma(1))+(1-w(1))*normpdf(x,mu(2),sigma(2));
error=sqrt(1/length(x1)*sum((f1(x1)-f).^2));
error1=sum(abs(f1(x1)-f));

