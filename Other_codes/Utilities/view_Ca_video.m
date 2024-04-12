function view_Ca_video()
warning off
[file,path] =uigetfile('*.h5');
in=[path,file];
V=h5read(in,'/Object');
videofig(size(V,3), @(frm,c) redraw(frm,c,V));
redraw(1,[],V);