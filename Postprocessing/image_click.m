function image_click(~,ev,app)

co=ev.IntersectionPoint(1:2);  
box_siz=app.m.XData(2)/10;

col=ceil(co(1)/box_siz);
ro=ceil(co(2)/box_siz);

ind = sub2ind([app.m.XData(2)/box_siz,ceil(length(app.ix_c)/10)],col,ro);

if ind<=length(app.ix_c)
    if app.ix_c(ind)
        hold(app.UIAxes, 'on')
        x = [50*col-49, 50*col-49, 50*col, 50*col, 50*col-49];
        y = [50*ro-49, 50*ro, 50*ro, 50*ro-49, 50*ro-49];
        plot(x, y, 'g-', 'LineWidth', 3,'parent',app.UIAxes,'tag',num2str(ind));
        app.ix_c(ind)=false;
    else
        obj=findobj(app.UIAxes.Children,'Tag',num2str(ind));
        delete(obj);
        app.ix_c(ind)=true;
    end
end

 hold(app.UIAxes, 'off')


