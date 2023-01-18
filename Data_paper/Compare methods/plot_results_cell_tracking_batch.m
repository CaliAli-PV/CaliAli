function p=plot_results_cell_tracking_batch(varargin)
% p=plot_results_cell_tracking_batch(R80,R60,R40,R20);
% p=plot_results_cell_tracking_batch(L,S,R,noise);
% p=plot_results_cell_tracking_batch(out);
% p=plot_results_cell_tracking_batch(MultiS2);


n=size(varargin,2);
lab=varargin{1, 1}.Properties.VariableNames;

figure;set(gcf, 'Position',  [100, 20, 800, 150*n]);tiledlayout(n,4);
p=[];
for i=1:n
    temp=plot_results_cell_in(varargin{1, i},lab);
    p=cat(1,p,temp');
    if i==1
        h = findobj('Type','Axes');
        title(h(3,1),'F1');
        title(h(2,1),'Recall');
        title(h(1,1),'Precision');

    end
end

end

function p=plot_results_cell_in(in,lab)
if size(in,1)==1
    plotci=0;
else
    plotci=1;
end
S=[];
for i=1:size(in,2)
    temp=in{:,i};
    [CR.f1,CR.Sen,CR.PPV,CR.x]=separate_errors(temp);
    S=cat(2,S,CR);
end
S=squeeze(struct2cell(S));

nexttile;
p(1,:)=plot_figures(S{end, 1},S(1,:),plotci);
ylim([0 1]);
nexttile;
p(2,:)=plot_figures(S{end, 1},S(2,:),plotci);
ylim([0 1]);
nexttile;
[p(3,:),handle]=plot_figures(S{end, 1},S(3,:),plotci);
ylim([0 1]);
lgd=legend(handle,lab);
lgd.Layout.Tile = lgd.Layout.Tile+1;
end


function [F1,Sen,PPV,x]=separate_errors(T)

x=linspace(0,1,size(T(1).t,1))';

F1=[];
Sen=[];
PPV=[];

for i=1:size(T,1)
    F1=cat(2,F1,T(i).t.(1));
    Sen=cat(2,Sen,T(i).t.(2));
    PPV=cat(2,PPV,T(i).t.(3));
end

F1(isnan(F1))=0;
Sen(isnan(Sen))=0;
PPV(isnan(PPV))=0;

end

function [p,Handle]=plot_figures(x,in,plotci)
for i=1:size(in,2)-1
    [p(i),d(i)]=get_singificant_distance_curves(in{1,end-1},in{1,i});
end
hold on
co=distinguishable_colors(size(in,2));
if plotci==1
    for i=1:size(in,2)
        t=in{1,i}';
        t(isnan(t))=0;
        temp=bootci(10000,@(x)mean(x,1,'omitnan'),t);
        y(1,:,i)=mean(in{1,i},2);
        y(2,:,i)=temp(1,:);
        y(3,:,i)=temp(2,:);
    end
else
    for i=1:size(in,2)
        y(1,:,i)=mean(in{1,i},2);
        y(2,:,i)=mean(in{1,i},2)-std(in{1,i},[],2)/sqrt(size(in{1,i},2));
        y(3,:,i)=mean(in{1,i},2)+std(in{1,i},[],2)/sqrt(size(in{1,i},2));
    end
end


y(isnan(y))=0;
for i=1:size(in,2)
    h = plot_ci(x,y(:,:,i),'PatchColor', co(i,:), 'PatchAlpha', 0.2, ...
        'MainLineWidth', 2, 'MainLineStyle', '-', 'MainLineColor', co(i,:), ...
        'LineWidth', 1.5, 'LineStyle','none');
    Handle(i)=h.Plot;
    xlim([0.5 1])
    ylim([0 1])
end
%%
xlabel('Similarity Threshold');
hold off
end
