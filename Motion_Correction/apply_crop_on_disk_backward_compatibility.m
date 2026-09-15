function apply_crop_on_disk_backward_compatibility(Flist,options_main)
%% Check files that carry no valid-region record, and warn rather than crop.
%
% A file reaching alignment with an empty motion_correction.Mask was not
% corrected by CaliAli. Either it came from an external tool, or it predates the
% version that started recording the mask.
%
% THIS FUNCTION USED TO CROP THEM. It called square_borders(Y, 0), which treats
% every pixel equal to 0 as a border left by a translation. That inference held
% only while the pipeline added 1 to every recording so that 0 could not occur in
% real data. The offset is gone, so a genuinely dark pixel is now
% indistinguishable from a filled one, and the crop was quietly deleting real
% columns -- one of them off a session in the benchmark, with no message.
%
% There are no recorded shifts for such a file, so there is nothing to propagate
% and no way to be sure. The borders are therefore reported, with the evidence,
% and left alone. Removing them is the user's job; the FAQ already asks this of
% anyone using an external motion-correction tool.
%
% Author: Pablo Vergara

if ~exist('options_main','var')
    options_main=[]; %#ok<NASGU>
end

if ischar(Flist)
    Flist={Flist};
end

unrecorded = {};
for i=1:length(Flist)
    f = Flist{i};
    if iscell(f), f = f{1}; end
    try
        if isempty(CaliAli_load(f,'CaliAli_options.motion_correction.Mask'))
            unrecorded{end+1} = f; %#ok<AGROW>
        end
    catch
        unrecorded{end+1} = f; %#ok<AGROW>
    end
end

if ~isempty(unrecorded)
    report_uncropped_borders(unrecorded);
end

end
