function displayNestedStructure(obj,maxDepth)
fprintf('%s└─ %s\n', prefix, fieldname);
print_structure(obj, '', maxDepth);
end

function print_structure(obj, prefix, maxDepth, currentDepth)
    % Check input arguments and set defaults
    if nargin < 3
        maxDepth = Inf;  % Default to unlimited depth
    end
    if nargin < 4
        currentDepth = 0;  % Start at depth 0
    end

    % Check if the input argument is a struct or object
    if isstruct(obj)
        fields = fieldnames(obj);
    elseif isobject(obj)
        fields = properties(obj);
    else
        return;  % Not a valid structure or object
    end

    % Sort fields based on the number of subfields (or properties)
    numSubfields = zeros(length(fields), 1);
    for i = 1:length(fields)
        fieldname = fields{i};
        value = obj.(fieldname);

        if isstruct(value) || isobject(value)
            % Count the number of subfields (or properties)
            if isstruct(value)
                subfields = fieldnames(value);
            elseif isobject(value)
                subfields = properties(value);
            end
            numSubfields(i) = length(subfields);
        end
    end

    % Sort fields based on the number of subfields in descending order
    [~, idx] = sort(numSubfields, 'ascend');
    sortedFields = fields(idx);

    % Loop through each sorted field
    for i = 1:length(sortedFields)
        fieldname = sortedFields{i};
        value = obj.(fieldname);

        % Display the field name with appropriate indentation
        fprintf('%s└─ %s\n', prefix, fieldname);

        % Recursively call print_structure for nested structures (if within maxDepth)
        if (isstruct(value) || isobject(value)) && (currentDepth < maxDepth)
            % For nested structures, adjust the prefix for indentation
            subprefix = [prefix '   │']; % Indentation for subfields
            print_structure(value, subprefix, maxDepth, currentDepth + 1);
        end
    end
end
