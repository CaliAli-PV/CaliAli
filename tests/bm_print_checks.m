function bm_print_checks(C)
for i = 1:numel(C)
    if C(i).pass
        fprintf('  [pass] %-52s %s\n', C(i).name, C(i).detail);
    else
        fprintf(2,'  [FAIL] %-52s %s\n', C(i).name, C(i).detail);
    end
end
end
