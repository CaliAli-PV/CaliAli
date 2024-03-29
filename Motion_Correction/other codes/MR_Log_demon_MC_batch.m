function [X1,X2,D]=MR_Log_demon_MC_batch(X1,X2,opt)

X1=v2uint8(X1);
X2=v2uint8(X2);
%% Parameters
if ~exist('opt','var')
opt=get_default_options();
end
nlevel=size(X1,3);

%% Multiresolution
it=0;
for k=nlevel:-1:1
    opt_t=opt{k};
    it=it+1;
    % downsample
    scale = 2^-(k-1);
    
    F=X1(:,:,k);
    M=X2(:,:,k);
    
    Fl = imresize(F,scale);
    Ml = imresize(M,scale);
%     implay(cat(3,Fl,Ml));
    % register
    [MP,~,~,vxl,vyl] = register_in(Fl,imhistmatch(Ml,Fl), opt_t);
%     implay(cat(3,Fl,MP));
    % upsample
    vx = imresize(vxl/scale,size(M));
    vy = imresize(vyl/scale,size(M));
    [sx(:,:,:,it),sy(:,:,:,it)] = expfield(vx,vy);
    
    for i=1:size(X1,3)
        X2(:,:,i)  = uint8(imwarp(double(X2(:,:,i)),cat(3,sy(:,:,:,it),sx(:,:,:,it)),'FillValues',0));
    end
%     implay(cat(3,X1(:,:,3) ,X2(:,:,3) ));
    
end
sx=sum(sx,4);
sy=sum(sy,4);


D=cat(4,sy,sx);

end

function opt=get_default_options()
opt{3} = struct('niter',15, 'sigma_fluid',0.5,...
    'sigma_diffusion',5, 'sigma_i',1,...
    'sigma_x',1, 'do_display',0, 'do_plotenergy',0);

opt{2} = struct('niter',15, 'sigma_fluid',1,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1.2, 'do_display',0, 'do_plotenergy',0);


opt{1} = struct('niter',15, 'sigma_fluid',1.5,...
    'sigma_diffusion',2, 'sigma_i',1,...
    'sigma_x',1.2, 'do_display',0, 'do_plotenergy',0);

end







opt{1,1}  = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',5, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{2,1} = struct('niter',100, 'sigma_fluid',1,...
    'sigma_diffusion',5, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{3,1} = struct('niter',20, 'sigma_fluid',3,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',1, 'do_display',plotme, 'do_plotenergy',plotme);
opt{4,1} = struct('niter',20, 'sigma_fluid',3,...
    'sigma_diffusion',3, 'sigma_i',1,...
    'sigma_x',2, 'do_display',plotme, 'do_plotenergy',plotme);

