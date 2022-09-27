function probability=compute_gmm_probability_low(x,w,mu,sigma,min_x,max_x)
% Construct probaiblities using gaussian mixture model
% input: 
%   x: constant or vector at which probabilities will be evaluated
%   w: weights for components
%   mu: means for components
%   sigma; standard deviation for components
%   min_x/max_x: minimal and maximal values in dataset
% output:
%   probability for inputted x value
%Author: Kevin Johnston, University of California, Irvine
%component identifications via bayes rule
f= @(x) (w(1)*normpdf(x,mu(1),sigma(1)))./(w(1)*normpdf(x,mu(1),sigma(1))+w(2)*normpdf(x,mu(2),sigma(2)));


%Find highest and lowest probability, and normalize to 1 and 0.
y=min_x:.01:max_x;
[minim,I1]=min(f(y));
[maxim,I2]=max(f(y));
for i=1:length(x)
    if x(i)<y(I2)
        probability(i)=maxim;
    elseif x(i)>y(I1)
        probability(i)=minim;
    else
        probability(i)=f(x(i));
    end
end
probability=(probability-minim)/(maxim-minim);
for i=1:length(x)
    probability(i)=min(probability(i),1);
    probability(i)=max(probability(i),0);
end
%probability=probability';