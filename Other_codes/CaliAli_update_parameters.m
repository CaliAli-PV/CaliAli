function CaliAli_update_parameters(varargin)
theFiles = uipickfiles('FilterSpec','*.mat');

if ~isempty(varargin)
    par=struct(varargin{:});
    for i=progress(1:size(theFiles,1))
        load(theFiles{i})
        fn = fieldnames(par);  % Get the field names of B
        for k = 1:numel(fn)
            CaliAli_options = update_field(CaliAli_options, fn{k}, par.(fn{k}));
        end
     CaliAli_save(theFiles{i}(:),CaliAli_options);
    end

end

end

function s = update_field(s, field_name, new_value)
%UPDATE_FIELD Recursively updates all fields with a given name in a structure.
%   s = UPDATE_FIELD(s, field_name, new_value) takes a structure 's', a 
%   field name 'field_name', and recursively traverses through its fields. 
%   Any field matching 'field_name' is updated to the value specified 
%   in 'new_value'.

  fields = fieldnames(s);
  for i = 1:numel(fields)
    field = fields{i};
    if isstruct(s.(field))&~isstruct(new_value)
      % If the field is a nested structure, recursively call the function
      s.(field) = update_field(s.(field), field_name, new_value);
    elseif strcmp(field, field_name)
      % If the field name matches the target field_name, update its value
      s.(field) = new_value;
    end
  end
end


