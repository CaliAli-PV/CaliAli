function c = bm_chk_true(name, cond, detail)
c = struct('name',name,'pass',logical(cond),'detail',char(detail));
end
