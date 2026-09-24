function results = bm_finish(results)
%% Stamp the record and write it out.
results.finished = datestr(now); %#ok<TNOW1,DATST>
if isfield(results,'out_dir') && ~isempty(results.out_dir)
    f = fullfile(results.out_dir,'benchmark_results.mat');
    save(f, 'results', '-v7.3');
    fprintf('\nresults saved to %s\n', f);
end
end
