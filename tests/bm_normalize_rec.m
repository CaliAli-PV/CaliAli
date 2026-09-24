function rec = bm_normalize_rec(rec, fields)
%% bm_normalize_rec: Give every record the same fields in the same order.
%
% Inputs:
%   rec, fields - A record and the full field list.
%
% Outputs:
%   rec - The record with every field present.

for i = 1:numel(fields)
    if ~isfield(rec, fields{i})
        rec.(fields{i}) = [];
    end
end
extra = setdiff(fieldnames(rec), fields);
if ~isempty(extra), rec = rmfield(rec, extra); end
rec = orderfields(rec, fields);
end
