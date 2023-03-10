function create_links_SCOUT_long_term_tracking()
theFiles = uipickfiles('FilterSpec','*.h5');theFiles(end)
[path,file,~]=fileparts(theFiles{end});
load([path,'\',file,'_Aligned.mat']);
V=h5read([path,'\',file,'_Aligned.h5'],'/Object');

f=[0,cumsum(F)];

for i=1:length(f)-2
    temp=V(:,:,f(i)+1:f(i+2));
    [path,file,~]=fileparts(theFiles{i});
    out=[path,'\',file,'_link.h5'];
    saveash5(temp,out);
    get_CnPNR_from_video(2.5,{out});
end
end





        
        
        