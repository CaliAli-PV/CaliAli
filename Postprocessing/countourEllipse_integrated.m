function BW=countourEllipse_integrated(vec,alpha);
points=1000;
mu=mean(vec,1);
ran=[min(vec-mu,[],1);max(vec-mu,[],1)].*3+mu;
C(:,1)=linspace(ran(1,1),ran(2,1),points);
C(:,2)=linspace(ran(1,2),ran(2,2),points);
coor=(vec-min(C))./range(C).*points;
% alpha=1-logspace(-0.05,-4,10);

% alpha=[.9 .95 .99 .999 .9999];

BW=zeros(points);
for i=1:size(alpha,2);
s = chi2inv(alpha(i),2);
Sigma=cov(coor(:,1),coor(:,2));
mu=mean(coor,1);
[V, D] = eig(Sigma * s);
t = linspace(0, 2 * pi);
a = ((V * sqrt(D)) * [cos(t(:))'; sin(t(:))'])'+mu;
BW = max(cat(3,BW,poly2mask(a(:,1),a(:,2),points,points).*(1-alpha(i))),[],3);
end


if size(alpha,2)>1
contour(C(:,1),C(:,2),BW,(1-alpha)');
else
contour(C(:,1),C(:,2),BW,1);
end
set(gca,'ZScale', 'log')
hold on;
scatter(vec(:,1),vec(:,2),'filled','MarkerEdgeColor','k','MarkerFaceColor',[127,127,127]./255);
set(gca,'ColorScale','log');caxis([0.00001 1])


