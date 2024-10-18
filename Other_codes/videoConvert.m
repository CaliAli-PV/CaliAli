function output = videoConvert(input)
    % videoConvert: Converts between 3D array and cell array representations of a video.
    %
    % If input is a 3D array (d1 x d2 x F), it converts to a cell array (1 x F)
    % If input is a cell array (1 x F), it converts back to a 3D array (d1 x d2 x F)
    
    if isnumeric(input) && ndims(input) == 3
        % Case 1: Input is a 3D array (d1 x d2 x F), convert to cell array
        F = size(input, 3);
        output = cell(1, F);
        for i = 1:F
            output{i} = input(:, :, i);
        end
    elseif iscell(input) && ismatrix(input) && all(cellfun(@(x) ndims(x) == 2, input))
        % Case 2: Input is a cell array (1 x F), convert to 3D array
        F = length(input);
        [d1, d2] = size(input{1});
        output = zeros(d1, d2, F);
        for i = 1:F
            output(:, :, i) = input{i};
        end
    else
        error('Input must be either a 3D numeric array or a 1xF cell array.');
    end
end
