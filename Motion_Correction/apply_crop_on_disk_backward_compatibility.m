function apply_crop_on_disk_backward_compatibility(Flist)
% Crop borders on disk by building a mask from the first frame (pixels == 0 are removed),
% and update ONLY CaliAli_options.motion_correction.Mask without overwriting other fields.
%
% mat_path : path to .mat file containing the video variable
% varname  : name of the video variable (default 'Y')

for i=1:length(Flist)
    try
        if isempty(CaliAli_load(Flist{i},'CaliAli_options.motion_correction.Mask'))
            apply_crop_on_disk_in(Flist{i}) % If mask is zero, calculate.
        end
    catch
        apply_crop_on_disk_in(Flist{i}) % If mask doesnt exist, calculate.
    end
end

end

function apply_crop_on_disk_in(mat_path)
CaliAli_options=CaliAli_load(mat_path, 'CaliAli_options');
Flist=create_batch_list({mat_path}, CaliAli_options.motion_correction.batch_sz,'');

for k=1:length(Flist)
    Y = CaliAli_load(Flist{k}, 'Y');


    if Flist{k}{3}>1
        intra_sess_tag= true;
    else
        intra_sess_tag= false;
    end

    if intra_sess_tag
        [~,m] = square_borders(Y, 0);
        Mask(Mask>0)=m(Mask>0);
    else
        [~,Mask] = square_borders(Y, 0);
    end
end

CaliAli_options.motion_correction.Mask=Mask;
CaliAli_save(mat_path,CaliAli_options);
apply_crop_on_disk(mat_path);
end