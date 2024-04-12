function [X1,X2,D,tS,im,e]=MR_Log_demon(X1,X2,opt)

X1=v2uint8(X1);
X2=v2uint8(X2);
%% Parameters
if ~exist('opt','var')
    opt = struct('stop_criterium',0.001,'imagepad',1.5,'niter',5, 'sigma_fluid',1,...
        'sigma_diffusion',1, 'sigma_i',1,...
        'sigma_x',1, 'do_display',0, 'do_plotenergy',0);
end

nlevel=size(X1,3):-1:1;

%% Multiresolution
it=0;
for k=nlevel
    if size(opt,1)>1
        t_opt=opt{nlevel(k)};
    else
        t_opt=opt;
    end
    it=it+1;
    % downsample
    scale = 2^-(k-1);

    F=X1(:,:,k);
    M=X2(:,:,k);

    Fl = imresize(F,scale);
    Ml = imresize(M,scale);
    % [MP,~,~,vxl,vyl,im{k},e{k}] = register_in_lite_mex(Fl,Ml,t_opt);
    % For debugging
     [MP,~,~,vxl,vyl,im{k},e{k}] = register_in(Fl,Ml,t_opt);
    % [MP,~,~,vxl,vyl,im{k},e{k}] = register_in(Fl,Ml,t_opt);

    %     implay(cat(3,Fl,MP));
    % upsample
    vx = imresize(vxl/scale,size(M));
    vy = imresize(vyl/scale,size(M));
    [sx(:,:,:,it),sy(:,:,:,it)] = expfield(vx,vy);

    for i=1:size(X1,3)
        X2(:,:,i)     = uint8(imwarp(double(X2(:,:,i)),cat(3,sy(:,:,:,it),sx(:,:,:,it)),'FillValues',0));
    end
    %     implay(cat(3,X1(:,:,3) ,X2(:,:,3) ));

end
tS=cat(3,sy,sx);
sx=sum(sx,4);
sy=sum(sy,4);


D=cat(4,sy,sx);

end


