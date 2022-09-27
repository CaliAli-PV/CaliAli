function view_Ca_video()
warning off
[file,path] =uigetfile('*.h5');
in=[path,file];
V=h5read(in,'/Object');
Ca_video_viewer(V); 