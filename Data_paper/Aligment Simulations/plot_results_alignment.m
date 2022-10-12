function plot_results_alignment(dist,ci)
%  plot_results_alignment(T,0)
figure;set(gcf, 'Position',  [100, 20, 800, 150]);
tiledlayout(1,size(dist,2)+1);
x=linspace(0,1,1000);
lab=dist.Properties.RowNames;
tt=dist.Properties.VariableNames;
for i=1:size(dist,2)  
    nexttile;
    Handle=plot_figures(x,dist(:,i),ci);
    if i==size(dist,2)
    lgd=legend(Handle,lab);
    lgd.Layout.Tile = lgd.Layout.Tile+1;
    end
    title(tt{1,i})
end

end

function Handle=plot_figures(x,in,plotci)
hold on
co=distinguishable_colors(size(in,1));
if plotci==1
    for i=1:size(in,1)
        t=cell2mat(in{i,1})';
        t(isnan(t))=0;
        temp=bootci(10000,@(x)mean(x,1,'omitnan'),t);
        y(1,:,i)=mean(t);
        y(2,:,i)=temp(1,:);
        y(3,:,i)=temp(2,:);
    end
else
    for i=1:size(in,1)
                t=cell2mat(in{i,1})';
        t(isnan(t))=0;
        y(1,:,i)=mean(t);
        y(2,:,i)=mean(t)-std(t)/sqrt(size(t,1));
        y(3,:,i)=mean(t)+std(t)/sqrt(size(t,1));
    end
end


y(isnan(y))=0;
for i=1:size(in,1)
    h = plot_ci(x,y(:,:,i)','PatchColor', co(i,:), 'PatchAlpha', 0.2, ...
        'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', co(i,:), ...
        'LineWidth', 1.5, 'LineStyle','none');
    Handle(i)=h.Plot;
    xlim([0.5 1])
    ylim([0 100])
end
%%
xlabel('Similarity Threshold');
hold off
end
