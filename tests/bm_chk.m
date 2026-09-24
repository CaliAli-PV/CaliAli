function c = bm_chk(name, got, want)
c = struct('name',name,'pass',isequal(got,want), ...
    'detail',sprintf('got %s, want %s', bm_tostr(got), bm_tostr(want)));
end
