

function [w,mu,sigma,error]=gemm_classification(X,num_iter)
% Creates parameters for gaussian-exponential mixture model using data X

        X=X-min(X);
        minim=min(X)-.001;
        maxim=max(X)+.001;
        %minim=min(X)-max(X);

if ~exist('num_iter','var')
    num_iter=100;
end
warning('off','all')
init_bandwidth=optimal_bandwidth(X);
[f,x1,bw]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Bandwidth',init_bandwidth);
[f,x1,def_bw]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Bandwidth',init_bandwidth);
bw=min(init_bandwidth,def_bw);

if f(1)==0
    f(1)=f(2);
end
if f(end)==0;
    f(end)=f(end-1);
end
modelfun=@(b,x) b(1)*exppdf(x,b(2))+(1-b(1))*normpdf(x,b(3),b(4));
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
beta=nlinfit(x1,f,modelfun,[.5,model_min,model_max,unifrnd(.01,.15)]);
[warnMsg,warnId]=lastwarn;
if isempty(warnMsg)
mu=[mu;[beta(2),beta(3)]];
Sigma=[Sigma;beta(4)];
w=[w;[beta(1),1-beta(1)]];
end
end
for i=2:num_iter
try
warning('');
init_beta=[unifrnd(.25,.75),unifrnd(model_min,model_max),unifrnd(model_min,model_max),unifrnd(.01,.5)];
opts=statset('MaxIter',300);
beta=nlinfit(x1,f,modelfun,init_beta,opts);
[warnMsg,warnId]=lastwarn;
if isempty(warnMsg)
mu=[mu;[beta(2),beta(3)]];
Sigma=[Sigma;beta(4)];
w=[w;[beta(1),1-beta(1)]];
end
end
end
if isempty(mu)
    iter=iter+1;
    [f,x1]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Bandwidth',bw);
end
end
warning('on','all')
% [mu,ind]=sort(mu,2);
% ind=reshape(ind,1,[]);
% first_col=find(ind==1);
% 
% 
% w=reshape(w,1,[]);
% w=[w(first_col)',w(setdiff(1:length(w),first_col))'];

ind_del=find(sum(isnan(w),2)>0|min(w,[],2)<0|max(w,[],2)>1);
w(ind_del,:)=[];
Sigma(ind_del,:)=[];
mu(ind_del,:)=[];



w=round(w,4);
Sigma=round(Sigma,4);
mu=round(mu,4);
mode_weight_w=mode(w,1);

mode_weight_S=mode(Sigma,1);

mode_weight_mu=mode(mu,1);
if mu(1)==0
    mu(1)=10^(-4);
end
ind_del=find(abs(sum(w-mode_weight_w,2))>10^(-3)|abs(sum(Sigma-mode_weight_S,2))>10^(-3)|abs(sum(mu-mode_weight_mu,2))>10^(-3));

w(ind_del,:)=[];
mu(ind_del,:)=[];
Sigma(ind_del,:)=[];


w=trimmean(w,10,1);
mu=trimmean(mu,10,1);
sigma=trimmean(Sigma,10,1);
w=w/sum(w);

f1= @(x)w(1)*exppdf(x,mu(1))+(1-w(1))*normpdf(x,mu(2),sigma(1));
error=sqrt(1/length(x1)*sum((f1(x1)-f).^2));


