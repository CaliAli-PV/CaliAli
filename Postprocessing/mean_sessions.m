function out=mean_sessions(S)
out = cellfun(@(a) mean(a,2), S, 'UniformOutput', false);
out=catpad(2,[],out{:});