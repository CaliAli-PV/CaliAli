function process_folder(fullFileName,opt)
files=dir([fullFileName,filesep,'*',opt.file_extension]);  
opt.input_files   = fullfile({files.folder}, {files.name})';
CaliAli_options=CaliAli_downsample(opt);


folders = strsplit(CaliAli_options.downsampling.output_files{1, 1}, filesep);

out_dir = fileparts(CaliAli_options.downsampling.output_files{1});
[parent_dir, session_dir] = fileparts(out_dir);
if isempty(parent_dir)
    parent_dir = out_dir;
end
if ~exist(parent_dir, 'dir')
    mkdir(parent_dir);
end
outpath = fullfile(parent_dir, [session_dir '_con.mat']);
CaliAli_concatenate_files(outpath,CaliAli_options.downsampling.output_files);


