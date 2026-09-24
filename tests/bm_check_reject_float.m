function C = bm_check_reject_float()
%% bm_check_reject_float: A floating-point datatype must be refused, and clearly.
%
% The pipeline clips against integer maxima and subtracts integers from the data
% during extraction, so a float recording has never survived it. What matters is
% where it is refused: at the moment the option is set, naming the classes that
% are allowed, rather than several stages later when a partial write of a
% mismatched class fails.
%
% Inputs:
%   None.
%
% Outputs:
%   C - Cell array of check results.

C = {};
for cls = {'single','double','int16'}
    try
        CaliAli_parameters('output_class', cls{1});
        C{end+1} = bm_chk_fail(sprintf('output_class %s is refused', cls{1}), ...
            'it was accepted'); %#ok<AGROW>
    catch ME
        C{end+1} = bm_chk_true(sprintf('output_class %s is refused', cls{1}), ...
            true, bm_first_line(ME.message)); %#ok<AGROW>
    end
end

for cls = {'uint8','uint16','uint32'}
    try
        o = CaliAli_parameters('output_class', cls{1});
        C{end+1} = bm_chk(sprintf('output_class %s is accepted', cls{1}), ...
            o.downsampling.output_class, cls{1}); %#ok<AGROW>
    catch ME
        C{end+1} = bm_chk_fail(sprintf('output_class %s is accepted', cls{1}), ...
            ME.message); %#ok<AGROW>
    end
end
end
