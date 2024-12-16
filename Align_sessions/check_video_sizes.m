function temp=check_video_sizes(opt,temp,fullFileName)

[d1,d2]=size(opt.Mask);
rem_pixels=reshape(opt.Mask(:)~=temp.opt.Mask(:),d1,d2);
rem_pixels=rem_pixels(:);


if sum(rem_pixels)>0
    [filepath,name]=fileparts(fullFileName);
    %%calculate new mask
    [l1,l2]=size(temp.Cn);
    new_mask=~reshape(rem_pixels(temp.opt.Mask(:)),l1,l2);
    %% reshape video with new mask
    vid_in=strcat(filepath,filesep,name,'_det','.h5');
    V=h5read(vid_in,'/Object');
    [d1,d2,~]=size(V);
    V=reshape(V,d1*d2,[]);
    new_d1=sum(sum(new_mask,2)>0,1);
    new_d2=sum(sum(new_mask,1)>0,2);
    new_mask=new_mask(:);
    V=V(new_mask,:);
    V=reshape(V,new_d1,new_d2,[]);
    %% reshape projections
    for i=1:size(temp.P,2);
        t=reshape(temp.P.(i){1,1},d1*d2,[]); 
        t=t(new_mask,:);
        temp.P.(i){1,1}=reshape(t,new_d1,new_d2,[]);
    end
    %% reshape Cn and PNR
    t=reshape(temp.Cn,d1*d2,[]);
    t=t(new_mask,:);
    temp.Cn=reshape(t,new_d1,new_d2,[]);
    t=reshape(temp.PNR,d1*d2,[]);
    t=t(new_mask,:);
    temp.PNR=reshape(t,new_d1,new_d2,[]);
    %% replace old mask
    temp.opt.Mask=opt.Mask;
    %% Save Variables
    P=temp.P;
    F=temp.F;
    opt=temp.opt;
    Cn=temp.Cn;
    PNR=temp.PNR;
    save(strcat(filepath,filesep,name,'_det','.mat'),'P','F','opt','Cn','PNR','-append');
    delete(vid_in);
    saveash5(V,vid_in);
end

