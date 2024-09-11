function CaliAli_update_parameters(varargin)
theFiles = uipickfiles('FilterSpec','*.mat');

if ~isempty(varargin)
    par=struct(varargin{:});
    for i=progress(1:size(theFiles,1))
        load(theFiles{i})
        fn = fieldnames(par);  % Get the field names of B
        for k = 1:numel(fn)
            opt.(fn{k}) = par.(fn{k});  % Replace the corresponding fields in A
        end
     save(theFiles{i},'opt','-append');
    end

end

end


