function f=construct_probability_function_main(X,method,side);

%Construct arguments for identification probability function
%input
%   X: array of similarity values to be decomposed
%   method: string ('percentile','gmm','gemm','glmm','Kmeans') indicating
%       assignment method
%   side:   string ('left','right'), indicates which side of the dataset
%       has the highest similarity



%methods: gmm gemm glmm Kmeans percentile
%X(isoutlier(X))=[];
if isequal(side,'high')
    side='right';
elseif isequal(side,'low')
    side='left';
end
iter=1;
%if method is default, use all mixture models 3 times, and choose model
%with best approximation to smoothed X
if isequal(method,'default')
total=0;
f=cell(3,1);
    error=nan(3,1);
while iter<3&total<3

    
    j=1;
    if isnan(error(1,1))
    try
    method='gmm';
    [error(1,j),f{1,j}]=construct_probability_function(X,method,side);
    end
    end
    if isnan(error(2,1))
    try
    method='gemm';
    [error(2,j),f{2,j}]=construct_probability_function(X,method,side);
    end
    end
    if isnan(error(3,1))
    try
    method='glmm';
    [error(3,j),f{3,j}]=construct_probability_function(X,method,side);
    end
    end
    total=sum(~isnan(error));
    iter=iter+1;
    
end    
    error(error==0|isnan(error))=max(max(error));
    [m,I]=argmin_2d(error);
    f=f{I(1),I(2)};
    
    
  

else
    while iter<10
    try
    [~,f]=construct_probability_function(X,method,side);
    catch
        f=[];
    end
    iter=iter+1;
    if ~isempty(f)
        break
    end
    end
end

if ~exist('f','var')||isempty(f)
    warning('error calculating parameters, using percentile function for approximation')
    
    [~,f]=construct_probability_function(X,'percentile',side);
end
