function opt=CaliAli_motion_correction(varargin)

opt_all = CaliAli_parameters(varargin);
opt = opt_all.motion_correction;
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec','*.h5');
end


for k=1:length(opt.input_files)
    fullFileName = opt.input_files{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    opt.output_file=strcat(filepath,filesep,name,'_mc','.h5');
    if ~isfile(opt.output_file)
        Y=loadh5(fullFileName,'/Object');
        if isempty(gcp('nocreate'))
            % If no pool, create one
            parpool
        end
        [Y,ref]=Rigid_mc(Y,opt); %% Translation motion correction
        if opt.do_non_rigid
            Y=Non_rigid_mc(Y,ref,opt); %Non-rigid motion correction
        end
        %
        Y=interpolate_dropped_frames(Y);
        Y=square_borders(Y,0);
        %
        %% save MC video as .h5
        opt_all.motion_correction=opt;
        saveh5(Y,opt.output_file,'rootname','Object');
        saveh5(opt_all,opt.output_file,'append',1,'rootname','CaliAli_options')
    else
        fprintf(1, 'File %s already exist!\n', opt.output_file);
    end
end
