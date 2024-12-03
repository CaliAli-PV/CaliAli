function CaliAli_options=CaliAli_motion_correction(varargin)

CaliAli_options = CaliAli_parameters(varargin{:});
opt = CaliAli_options.motion_correction;
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec','*_ds*.mat');
end


for k=1:length(opt.input_files)
    fullFileName = opt.input_files{k};
    fprintf(1, 'Now reading %s\n', fullFileName);
    % output file:
    [filepath,name]=fileparts(fullFileName);
    opt.output_file=strcat(filepath,filesep,name,'_mc','.mat');
    out{k}=opt.output_file;
    if ~isfile(opt.output_file)
        Y=CaliAli_load(fullFileName,'Y');
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
        CaliAli_options.motion_correction=opt;
        CaliAli_save(opt.output_file(:),Y,CaliAli_options);
    else
        fprintf(1, 'File %s already exist!\n', opt.output_file);
    end
    CaliAli_options.motion_correction.output_files=out;
end

