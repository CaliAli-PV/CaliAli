function image_click_res(~,ev,app)

P     = get(ev.Source.Parent  , 'CurrentPoint');
P=[P(1,1),P(1,2)];
co=round(P);


scatter(co(1),co(2), ...
    'r.','parent',app.pnrAxes);
scatter(co(1),co(2), ...
    'r.','parent',app.cnAxes);
scatter(co(1),co(2), ...
    'r.','parent',app.pnrcnAxes);
scatter(co(1),co(2), ...
    'r.','parent',app.pnrAxes_2);
scatter(co(1),co(2), ...
    'r.','parent',app.cnAxes_2);
scatter(co(1),co(2), ...
    'r.','parent',app.pnrcnAxes_2);

app.seed(co(2), co(1))=1;
