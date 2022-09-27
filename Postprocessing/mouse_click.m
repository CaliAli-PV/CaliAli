function mouse_click(line,event,app)
B=event.Button;
t=str2double(get(line,'Tag'));
if B==1
    if ~ismember(t,app.cur)  %% add
        [~,C]=get_spat(app.neuron,t);
        plot_c(app,C,length(app.cur),t)
        for i=1:length(app.cur)
            set(findobj(app.mainAx,'Tag',num2str(app.cur(i))),'Color', 'k');
        end
        app.cur=[app.cur,t];
        line.Color='g';
        
    else % remove plot
        delete(findobj(app.Tr1,'tag',num2str(t)));
        app.cur(find(app.cur==t))=[];
        line.Color=app.c(t,:);
        for i=size(app.Tr1.Children,1):-1:1
            k=size(app.Tr1.Children,1)-i;
            app.Tr1.Children(i).YData=app.Tr1.Children(i).YData-median(app.Tr1.Children(i).YData)-k*20;
        end
        ylim(app.Tr1,[-20*length(app.Tr1.Children),40]);
    end
    
else %% right click delete    
    delete(findobj(app.Tr1,'tag',num2str(t)));
    app.cur(find(app.cur==t))=[];
    if isequal(app.c(t,:),[1,1,1])
    app.c(t,:)=[1.0000,0.3134,0.6866];
    else    
    app.c(t,:)=[1,1,1];
    end
    line.Color=app.c(t,:);
    for i=size(app.Tr1.Children,1):-1:1
        k=size(app.Tr1.Children,1)-i;
        app.Tr1.Children(i).YData=app.Tr1.Children(i).YData-median(app.Tr1.Children(i).YData)-k*20;
    end
    ylim(app.Tr1,[-20*length(app.Tr1.Children),40]);
end

end

function [A,C]=get_spat(in,t)
A=full(in.A(:,t));
dims=[in.options.d1  in.options.d2];
A = extract_patch(A,dims,[50,50]);
C=in.C_raw(t,:);

end

% function plot_a(app,A)
% cla(app.Sp1)
% I=imshow(A,[0,0.2],'Parent',app.Sp1);
% colormap(app.Sp1,'hot');
% app.Sp1.XAxis.TickLabels = {};
% app.Sp1.YAxis.TickLabels = {};
% % Set limits of axes
% app.Sp1.XLim = [0 I.XData(2)];
% app.Sp1.YLim = [0 I.YData(2)];
% end

function plot_c(app,C,nu,tag)
hold(app.Tr1,'on');
h = get(app.Tr1, 'Children');
set(h,'Color','k');
plot(C-nu*20,'g','Parent',app.Tr1,'tag',num2str(tag));
if length(C)>app.win
    app.Slider.Visible=1;
    xlim(app.Tr1,[0 app.win])
    ylim(app.Tr1,[-20*length(app.Tr1.Children),40]);
else
    app.Slider.Visible=0;
    app.Slider.Value=0;
end

end
