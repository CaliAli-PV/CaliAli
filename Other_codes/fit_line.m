function rho=fit_line(x,y,typ);
ki=x+y;
x(isnan(ki))=[];
y(isnan(ki))=[];

if ~exist('typ','var')
typ ='pearson';
end

if strcmp(typ,'spearman')
x=get_spearman_residuals(x);
y=get_spearman_residuals(y);
end

scatter(x,y,'k','filled')
grid on
grid minor

Fit = polyfit(x,y,1);
xFit = linspace(min(x), max(x), 50);
hold on;plot(xFit,polyval(Fit,xFit),'r','LineWidth',2);
% xlabel(xlab)
% ylabel(ylab)
% xlim([0,max(x)+(x(end)-x(end-1))]);

[rho,p]=corr(x,y);
disp([rho,p])
str=sprintf('r= %0.2f', rho);
% dim = [.6 .6 .1 .3];
% annotation('textbox',dim,'String',str,'FitBoxToText','on');
title(str);
hold off;