function in = apply_mask(in, Mask)
    % Function to apply a binary mask to an input image or data array.
    % The masked elements are removed, and the output is reshaped accordingly.
    %
    % Inputs:
    % - in: 3D array (d1 x d2 x d3) representing the input image or data array.
    % - Mask: 2D binary array (d1 x d2) representing the mask.
    %
    % Output:
    % - in: Masked and reshaped 3D array.

    % Get the dimensions of the input array
    [d1, d2, ~] = size(in);

    % Find the maximum number of true values in any row and column of the Mask
    f1 = max(sum(Mask, 1));
    f2 = max(sum(Mask, 2));

    % Reshape the input array to 2D (d1*d2 x d3)
    in = reshape(in, d1 * d2, []);

    % Reshape the mask to a column vector (d1*d2 x 1)
    Mask = reshape(Mask, d1 * d2, 1);

    % Remove the elements of 'in' where the mask is false
    in(~Mask, :) = [];

    % Reshape the resulting array back to 3D (f1 x f2 x d3)
    in = reshape(in, f1, f2, []);
end
