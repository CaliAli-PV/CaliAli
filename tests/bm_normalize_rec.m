function rec = bm_normalize_rec(rec, fields)
%% Give every record the same fields, in the same order.
for i = 1:numel(fields)
    if ~isfield(rec, fields{i})
        rec.(fields{i}) = [];
    end
end
extra = setdiff(fieldnames(rec), fields);
if ~isempty(extra), rec = rmfield(rec, extra); end
rec = orderfields(rec, fields);
end
