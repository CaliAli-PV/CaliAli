function c = bm_chk_num(name, got, want, tol)
c = struct('name',name,'pass',abs(double(got)-double(want)) <= tol, ...
    'detail',sprintf('got %g, want %g (tol %g)', got, want, tol));
end
