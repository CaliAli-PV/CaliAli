function out=trim_video(f1,f2)
[file,path] = uigetfile('*.h5');
[filepath,name]=fileparts(strcat(path,file));
Y=h5read(strcat(path,file),'/Object');
Y=Y(:,:,f1:f2);
out=strcat(filepath,'\',name,'_trim','.h5');
saveash5(Y,out);   
end