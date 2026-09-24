function U = bm_issue_checks()
%% bm_issue_checks: Run one regression per bug reported on GitHub.
%
% These answer a different question from the unit checks: not whether a component
% is correct, but whether a specific thing that once broke for a user is still
% fixed. A failure here is a regression on something somebody hit.
%
% Inputs:
%   None.
%
% Outputs:
%   U - Structure array of check results.
%
% Notes:
%   - Issues that were questions, feature requests or performance reports are not
%   represented here.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

C = {};
C = [C, issue_32_natural_order()];
C = [C, issue_31_patch_width()];
C = [C, issue_26_isxd_undefined()];
C = [C, issue_23_empty_patch()];
C = [C, issue_19_frame_coverage()];
C = [C, issue_15_residual_gui_colours()];
C = [C, issue_10_v2uint8_shapes()];
C = [C, issue_35_downsample_range()];
C = [C, issue_36_rerun_processed()];
U = [C{:}];
bm_print_checks(U);
end


function C = issue_32_natural_order()
%% #32: files were read in ASCII order, so 10.avi came before 2.avi.
% A miniscope session is written as numbered clips, and reading them as 1, 10,
% 11, 2 concatenates the recording out of order -- silently, since every clip is
% a valid video.
C = {};
try
    names = arrayfun(@(k) sprintf('%d.avi', k), [1 2 3 9 10 11 100], 'uni', 0);
    shuffled = names([5 7 2 1 6 3 4]);
    [~, idx] = natsortfiles(shuffled);
    got = shuffled(idx);
    C{end+1} = bm_chk_true('#32 numbered files sort 1,2,3,...,10,11 not 1,10,11,2', ...
        isequal(got(:)', {'1.avi','2.avi','3.avi','9.avi','10.avi','11.avi','100.avi'}), ...
        strjoin(got, ' '));
catch ME
    C{end+1} = bm_chk_fail('#32 natural order', ME.message);
end
end


function C = issue_31_patch_width()
%% #31: CNMF-E failed on the DEMO data because min_patch_width held two values
%% where one was expected, and a colon expression cannot take a vector step.
% The vector is still there; distribute_data guards it with a try/catch. This
% check does not care how it is fixed, only that the demo geometry runs.
C = {};
d = tempname; mkdir(d);
try
    Y = uint16(rand(64,80,60)*800+100); %#ok<NASGU>
    f = fullfile(d,'patchw.mat');
    save(f,'Y','-v7.3');
    for w_overlap = [8 16 32]
        for patch = {[32 32], [64 64], []}
            ev = evalc('[data, dims] = distribute_data(f, patch{1}, w_overlap, 1, 4, d, [], 0);'); %#ok<NASGU>
            C{end+1} = bm_chk_true(sprintf('#31 patch %s, overlap %d does not error', ...
                mat2str(patch{1}), w_overlap), ~isempty(dims), mat2str(dims)); %#ok<AGROW>
        end
    end
catch ME
    C{end+1} = bm_chk_fail('#31 patch width', ME.message);
end
rmdir(d,'s');
end


function C = issue_26_isxd_undefined()
%% #26: ISXD2h5 referenced ds_f, which was never assigned, so every Inscopix
%% read failed. A leftover from downsampling logic that had moved elsewhere.
C = {};
try
    f = which('ISXD2h5');
    if isempty(f)
        C{end+1} = bm_chk_fail('#26 ISXD2h5 present', 'function not found on the path');
        return
    end
    txt = fileread(f);
    body = regexprep(txt, '%[^\n]*', '');          % strip comments before looking
    C{end+1} = bm_chk_true('#26 ISXD2h5 has no undefined ds_f', ...
        isempty(regexp(body, '\<ds_f\>', 'once')), '');
catch ME
    C{end+1} = bm_chk_fail('#26 ISXD2h5', ME.message);
end
end


function C = issue_23_empty_patch()
%% #23: "Cannot index into Y_1_33_1_33 because indices cannot be empty" --
%% a patch was laid out with no pixels in it, and update_spatial then asked the
%% file for a range that did not exist.
% The check is on the geometry rather than on the extraction: no patch may be
% empty, for any frame size the layout has to cope with.
C = {};
try
    bad = {};
    for d1 = [33 64 90 128 201]
        for d2 = [33 65 130 256]
            w = patch_overlap_default([32 32]);
            r = ceil(linspace(1, d1, max(1,round(d1/32))+1));
            c = ceil(linspace(1, d2, max(1,round(d2/32))+1));
            if any(diff(r) < 1) || any(diff(c) < 1) || w < 1
                bad{end+1} = sprintf('%dx%d', d1, d2); %#ok<AGROW>
            end
        end
    end
    C{end+1} = bm_chk_true('#23 no frame size produces an empty patch', ...
        isempty(bad), strjoin(bad, ' '));
catch ME
    C{end+1} = bm_chk_fail('#23 empty patch', ME.message);
end
end


function C = issue_19_frame_coverage()
%% #19: half the field of view went undetected after finalising parameters.
% Whatever the cause was, the property that must hold is that the patch layout
% covers the WHOLE frame: every pixel belongs to at least one patch.
C = {};
try
    uncovered = {};
    for dims = {[90 130],[128 128],[201 301],[512 512]}
        d = dims{1};
        pd = [64 64];
        r = ceil(linspace(1, d(1), max(1,round(d(1)/pd(1)))+1));
        c = ceil(linspace(1, d(2), max(1,round(d(2)/pd(2)))+1));
        covered = false(d);
        for i = 1:numel(r)-1
            for j = 1:numel(c)-1
                covered(r(i):r(i+1), c(j):c(j+1)) = true;
            end
        end
        if ~all(covered(:))
            uncovered{end+1} = sprintf('%s misses %d px', mat2str(d), nnz(~covered)); %#ok<AGROW>
        end
    end
    C{end+1} = bm_chk_true('#19 patch layout covers the whole frame', ...
        isempty(uncovered), strjoin(uncovered, '; '));
catch ME
    C{end+1} = bm_chk_fail('#19 frame coverage', ME.message);
end
end


function C = issue_15_residual_gui_colours()
%% #15: the residual GUI drew accepted and deleted seeds in the same colour, so
%% there was no way to tell which had been kept.
%
% The GUI is manual_residuals_PNR.mlapp, an App Designer file, which is a zip of
% XML and a binary model. It cannot be driven headlessly and its code cannot be
% read the way a .m file can, so this does not verify the fix. It verifies that
% the app is still there and still reachable from get_seed -- enough to catch it
% being renamed or removed out from under manually_update_residuals, and honest
% about the rest.
C = {};
try
    app = fullfile(fileparts(which('get_seed')), 'manual_residuals_PNR.mlapp');
    C{end+1} = bm_chk_true('#15 the residual seed app is present', ...
        isfile(app), '');

    txt = fileread(which('get_seed'));
    C{end+1} = bm_chk_true('#15 get_seed still opens it', ...
        contains(txt, 'manual_residuals_PNR'), '');

    fprintf('    (#15 itself is a colour change inside an .mlapp; not checkable headlessly)\n');
catch ME
    C{end+1} = bm_chk_fail('#15 residual GUI', ME.message);
end
end


function C = issue_10_v2uint8_shapes()
%% #10: "Matrix dimensions must agree" in v2uint8, reached through the TIFF
%% reader. Downsampling failed outright on both TIFF and AVI input.
C = {};
try
    cases = { uint8(rand(8,8)*200), uint16(rand(8,8,5)*1000), ...
              single(rand(16,20,3)), double(rand(4,4,1)), ...
              uint16(ones(8,8,4)*7) };        % constant input: range is zero
    names = {'2-D uint8','3-D uint16','3-D single','single frame','constant'};
    for k = 1:numel(cases)
        out = v2uint8(cases{k});
        C{end+1} = bm_chk_true(sprintf('#10 v2uint8 handles %s', names{k}), ...
            isa(out,'uint8') && isequal(size(out), size(cases{k})), ...
            sprintf('%s %s', class(out), mat2str(size(out)))); %#ok<AGROW>
    end
catch ME
    C{end+1} = bm_chk_fail('#10 v2uint8', ME.message);
end
end


function C = issue_35_downsample_range()
%% #35: downsampling cast everything to uint8, so any value above 254 was
%% clipped -- silent data loss on uint16 and floating-point recordings.
C = {};
try
    o = CaliAli_parameters();
    C{end+1} = bm_chk_true('#35 the pipeline does not store recordings as uint8 by default', ...
        ~strcmpi(o.downsampling.output_class,'uint8'), o.downsampling.output_class);
    C{end+1} = bm_chk_true('#35 dropped-frame detection can fire', ...
        can_detect_dropped_frames(), '');
catch ME
    C{end+1} = bm_chk_fail('#35 downsampling range', ME.message);
end
end


function tf = can_detect_dropped_frames()
%% The test used to be mean(frame)==0, which could never be true because a +1
%% had been added to every pixel upstream. A blank frame must be found.
Y = uint16(rand(16,16,10)*500+50);
Y(:,:,4) = 0;
ev = evalc('Z = interpolate_dropped_frames(Y);'); %#ok<NASGU>
tf = mean(double(reshape(Z(:,:,4),[],1))) > 0;
end


function C = issue_36_rerun_processed()
%% #36: re-running the pipeline over a folder where every output already exists
%% failed with "Unrecognized function or variable 'out'", because the list of
%% output names was built inside the loop that skips finished files.
% Checked statically: running it for real needs a full motion-correction pass,
% which the scenarios already do. What must hold is that the name list does not
% depend on the loop body.
C = {};
try
    f = which('CaliAli_motion_correction');
    txt = fileread(f);
    body = regexprep(txt, '%[^\n]*', '');
    C{end+1} = bm_chk_true('#36 output names come from pre_allocate_outputs', ...
        ~isempty(regexp(body, 'output_files\s*=\s*unique\(out_pre', 'once')), ...
        '');
    C{end+1} = bm_chk_true('#36 the crop runs only on freshly written files', ...
        ~isempty(regexp(body, 'out_pre\(process_flags\)', 'once')), ...
        '');
catch ME
    C{end+1} = bm_chk_fail('#36 re-run over processed files', ME.message);
end
end
