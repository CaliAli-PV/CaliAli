function [error,f]=construct_probability_function(X,method,side)
%Construct identification probability assignment function
%input
%   X: array of similarity values to be decomposed
%   method: string ('percentile','gmm','gemm','glmm','Kmeans') indicating
%       assignment method
%   side:   string ('left','right'), indicates which side of the dataset
%       has the highest similarity




if isequal(method,'percentile')
    if isequal(side,'left')
        minim=min(X)-.001;
        maxim=max(X)+max(abs(X));
        [f1,x1]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Function','cdf');
        f1(end)=1;
        f= @(x)1-interp1(x1,f1,x);
    else
        maxim=max(X)+.001;
        minim=min(X)-max(abs(X));
        [f1,x1]=ksdensity(X,'Support',[minim,maxim],'BoundaryCorrection','Reflection','Function','cdf');
        
        f1(end)=1;
        
        f= @(x) interp1(x1,f1,x);
    end
    error=nan;
elseif isequal(method,'gmm')
    [w,mu,sigma,error]=gmm_classification(X,side);
    if sum(isnan(w))>0|sum(isnan(mu))>0|sum(isnan(sigma))>0
        f=[];
        return
    end
    if isequal(side,'left')
        
        f= @(x)compute_gmm_probability_low(x,w,mu,sigma,min(X),max(X));
    else
        f= @(x)compute_gmm_probability_high(x,w,mu,sigma,min(X),max(X));
    end
    
elseif isequal(method,'gemm')
    
    if isequal(side,'right')
        Y=X;
        X=max(1,max(X))-X-(1-max(X));
        
    end
    [w,mu,sigma,error]=gemm_classification(X);    
    if sum(isnan(w))>0|sum(isnan(mu))>0|sum(isnan(sigma))>0
       f=[];
       return
    end
    if isequal(side,'right')
    f= @(x)compute_gemm_probability(max(1,max(Y))-x-(1-max(Y)),w,mu,sigma,min(X),max(X));
    else
        f= @(x)compute_gemm_probability(x-min(X),w,mu,sigma,min(X),max(X));
    end
elseif isequal(method,'glmm')
    
    if isequal(side,'right')
        Y=X;
        X=max(1,max(X))-X-(1-max(X));
        
    end
    [w,mu,sigma,error]=glmm_classification(X);    
    if sum(isnan(w))>0|sum(isnan(mu))>0|sum(isnan(sigma))>0
       f=[];
       return
    end
    if isequal(side,'right')
    f= @(x)compute_glmm_probability(max(1,max(Y))-x-(1-max(Y)),w,mu,sigma,min(X),max(X));
    else
        f= @(x)compute_glmm_probability(x-min(X),w,mu,sigma,min(X),max(X));
    end
elseif isequal(method,'Kmeans')
    
    u=rand(size(X,2),1);
    u=[u,1-u];
    [center,u,J,num]=FuzzyKmeans(X,2,2,u,.00001);
    
    f= @(x)FuzzyKmeans_map(x,center,side);
    
    error=nan;
end


