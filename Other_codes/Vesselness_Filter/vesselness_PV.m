function vid=vesselness_PV(vid,use_parallel,sz,norm)

if ~exist('sz','var')
    sz=0.5:0.5:2;
end
if ~exist('norm','var')
    norm=0;
end

if ~exist('use_parallel','var')
    use_parallel=1;
end

if use_parallel
    b2 = ProgressBar(size(vid,3), ...
    'IsParallel', true, ...
    'UpdateRate', 1,...
    'WorkerDirectory', pwd(), ...
    'Title', 'Appling filter' ...
    );
    b2.setup([], [], []);
    vid = videoConvert(vid);
    parfor i=1:size(vid,2)
        temp=double(vid{i});
        temp=apply_vesselness_filter(temp,sz,norm);
        vid{i}=temp;
        updateParallel([], pwd);
    end
    b2.release();
    vid = videoConvert(vid);
else
    for i=1:size(vid,3)
        temp=double(vid(:,:,i));
        temp=apply_vesselness_filter(temp,sz,norm);
        vid(:,:,i)=temp;
    end
end
end

function out=apply_vesselness_filter(in,sz,norm)
% in= medfilt2(in);
Ip=mat2gray(in);
% Ip = single(in);
% thr = prctile(Ip(Ip(:)>0),1) * 0.9;
% Ip(Ip<=thr) = thr;
% Ip = Ip - min(Ip(:));
% Ip = Ip ./ max(Ip(:));    
% 
% % compute enhancement for two different tau values
 out = vesselness2D(Ip, sz, [1;1], 0.8, false,norm);
% out = vesselness2D(Ip, 0.05:0.05:1.5, [1;1], 1, false);
end