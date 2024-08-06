function C = add_displacements(A, B)
    C = A * 0;
    for i = 1:size(A, 4)
        C(:, :, :, i) = add_in(A(:, :, :, i), B);
    end
end

function C = add_in(A, B)
    % Check if the input displacement fields A and B have the same dimensions
    if ~isequal(size(A), size(B))
        error('Displacement fields A and B must have the same dimensions');
    end

    % Get the dimensions of the displacement fields
    [d1, d2, ~] = size(A);

    % Initialize the resulting displacement field C
    C = zeros(d1, d2, 2);

    % Create meshgrid for interpolation
    [X, Y] = meshgrid(1:d2, 1:d1);

    % Get displacements from A
    displacementA_x = A(:, :, 1);
    displacementA_y = A(:, :, 2);

    % Calculate new indices
    new_i = (1:d1)' + displacementA_y;
    new_j = (1:d2) + displacementA_x;

    % Ensure new indices are within bounds
    new_i = max(1, min(d1, new_i));
    new_j = max(1, min(d2, new_j));

    % Interpolate the displacements from B at the new positions
    displacementB_x = interp2(X, Y, B(:, :, 1), new_j, new_i, 'linear', 0);
    displacementB_y = interp2(X, Y, B(:, :, 2), new_j, new_i, 'linear', 0);

    % Sum the displacements to get the final displacement
    C(:, :, 1) = displacementA_x + displacementB_x;
    C(:, :, 2) = displacementA_y + displacementB_y;
end
