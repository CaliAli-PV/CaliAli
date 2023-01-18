function [list_out]=create_links_SCOUT_PV(list,file_path)
load([file_path,'_ses',num2str(size(list,2)-1),'_Aligned.mat']);
V=h5read([file_path,'_ses',num2str(size(list,2)-1),'_Aligned.h5'],'/Object');

f=[0,cumsum(F)];

for i=1:length(f)-2
    temp=V(:,:,f(i)+1:f(i+2));
    saveash5(temp,[file_path,'_ses',num2str(size(list,2)-1),'_Link_',sprintf('%02d',i),'.h5']);
    list_out{i,1}=[file_path,'_ses',num2str(size(list,2)-1),'_Link_',sprintf('%02d',i),'.h5'];
     get_CnPNR_from_video(2.5,{list_out{i,1}});
end
end





        
        
        