function C = bm_check_missing_options(files, dir_)
%% A file with no CaliAli_options must complain, not proceed on defaults.
%
% Silently substituting defaults is the worst outcome: the run completes and
% every number downstream is computed under settings the user never chose. The
% assertion is therefore about NOISE, not success -- an error or a warning, but
% not silence.
C = {};
try
    opt = CaliAli_demo_parameters();
    opt.downsampling.input_files = files;
    opt.downsampling.batch_sz = 0;
    opt = CaliAli_downsample(opt);
    ds = opt.downsampling.output_files;

    % strip the options out of the first file, as an older or hand-made file
    stripped = fullfile(dir_, 'no_options_ds.mat');
    copyfile(ds{1}, stripped);
    m = matfile(stripped, 'Writable', true);
    vars = whos(m);
    C{end+1} = bm_chk_true('the file had CaliAli_options to begin with', ...
        any(strcmp({vars.name},'CaliAli_options')), '');
    warning('off','all'); lastwarn('');
    complained = false; msg = '';
    try
        o2 = CaliAli_parameters();
        o2.inter_session_alignment.input_files = {stripped};
        evalc('CaliAli_align_sessions(o2);');
        [w, ~] = lastwarn;
        complained = ~isempty(w); msg = w;
    catch ME2
        complained = true; msg = ME2.message;
    end
    warning('on','all');
    C{end+1} = bm_chk_true('a file without CaliAli_options is reported', complained, ...
        bm_tern(complained, bm_first_line(msg), 'it ran silently on defaults'));
catch ME
    C{end+1} = bm_chk_fail('missing options', ME.message);
end
end
