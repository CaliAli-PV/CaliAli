function view_Ca_video()
warning off
[file,path] =uigetfile('*.mat');
in=[path,file];
V=CaliAli_load(in,'Y');
videofig(size(V,3), @(frm,c) redraw(frm,c,V));
redraw(1,[],V);