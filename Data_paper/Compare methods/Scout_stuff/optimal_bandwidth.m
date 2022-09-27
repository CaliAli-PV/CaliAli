function bw=optimal_bandwidth(X);
%This is 1/3 the standard estimator.
bw=.45*min(std(X),iqr(X)/1.34)*length(X)^(-1/5);