function image_click2(~,ev,app)

co=ev.IntersectionPoint(1:2);  
box_siz=app.m2.XData(2)/10;

col=ceil(co(1)/box_siz);
ro=ceil(co(2)/box_siz);

ind = sub2ind([app.m2.XData(2)/box_siz,ceil(length(app.ix_inc)/10)],col,ro);

if ind<=length(app.ix_inc)
    if ~app.ix_inc(ind)
        hold(app.UIAxes2, 'on')
        x = [50*col-49, 50*col-49, 50*col, 50*col, 50*col-49];
        y = [50*ro-49, 50*ro, 50*ro, 50*ro-49, 50*ro-49];
        plot(x, y, 'g-', 'LineWidth', 3,'parent',app.UIAxes2,'tag',num2str(ind));
        app.ix_inc(ind)=true;
    else
        obj=findobj(app.UIAxes2.Children,'tag',num2str(ind));
        delete(obj);
        app.ix_inc(ind)=false;
    end
end

 hold(app.UIAxes2, 'off')


