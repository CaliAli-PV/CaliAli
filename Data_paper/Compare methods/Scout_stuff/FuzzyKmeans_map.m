function probability=FuzzyKmeans_map(X,center,tail);
%Assigns fuzzy probability based on distance from two centers
%input
%   tail 'left' or 'right'
%   center: Kmeans centers
%   X: vector of locations to estimate probability
%output
%   probabilities at X

k=length(center);
q=2;
[small_val,I1]=min(center);
[large_val,I2]=max(center);
center=[small_val,large_val];
for i=1:length(X)
d=sqrt(sum((X(:,i)*ones(1,k)-center).^2,1));

d=d.^2;
        a=1./d.^(1/(q-1));
        b=sum(a); 
        probability(i,:)=a/b;

end
if isequal(tail,'left')
probability=probability(:,1);
for i=1:length(X)
    if X(i)<small_val
        %probability(i)=1-.1*(X(i)/small_val);
        probability(i)=1;
    elseif X(i)>large_val
        probability(i)=0;
    elseif X(i)<=large_val&&X(i)>=small_val;
        
        %probability(i)=probability(i)*(.9);
    end
end
else
    probability=probability(:,2);
for i=1:length(X)
    if X(i)>large_val
        %probability(i)=1-.1*((1-X(i))/(1-large_val));
        probability(i)=1;
    elseif X(i)<small_val
        probability(i)=0;
    elseif X(i)<=large_val&&X(i)>=small_val
        %probability(i)=.9*probability(i);
    end
end
end
probability=probability';