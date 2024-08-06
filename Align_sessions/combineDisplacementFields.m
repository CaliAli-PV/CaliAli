function C = combineDisplacementFields(A, B)
    % A and B are displacement fields of size d1xd2x2
    % A(:,:,1) and B(:,:,1) are the x-components
    % A(:,:,2) and B(:,:,2) are the y-components
    
    % Get the size of the displacement fields
    [rows, cols, ~] = size(A);
    
    % Initialize the combined displacement field
    C = zeros(rows, cols, 2);
    
    % Compute the combined displacement field
    for i = 1:rows
        for j = 1:cols
            % Calculate the new positions after applying A
            newX = i + A(i, j, 1);
            newY = j + A(i, j, 2);
            
            % Ensure the new positions are within bounds
            newX = min(max(1, newX), rows - 1);
            newY = min(max(1, newY), cols - 1);
            
            % Perform bilinear interpolation for Bx and By
            x1 = floor(newX);
            x2 = ceil(newX);
            y1 = floor(newY);
            y2 = ceil(newY);
            
            Q11_x = B(x1, y1, 1);
            Q21_x = B(x2, y1, 1);
            Q12_x = B(x1, y2, 1);
            Q22_x = B(x2, y2, 1);
            
            Q11_y = B(x1, y1, 2);
            Q21_y = B(x2, y1, 2);
            Q12_y = B(x1, y2, 2);
            Q22_y = B(x2, y2, 2);
            
            Bx_interp = (Q11_x * (x2 - newX) * (y2 - newY) + ...
                         Q21_x * (newX - x1) * (y2 - newY) + ...
                         Q12_x * (x2 - newX) * (newY - y1) + ...
                         Q22_x * (newX - x1) * (newY - y1));
                     
            By_interp = (Q11_y * (x2 - newX) * (y2 - newY) + ...
                         Q21_y * (newX - x1) * (y2 - newY) + ...
                         Q12_y * (x2 - newX) * (newY - y1) + ...
                         Q22_y * (newX - x1) * (newY - y1));
            
            % Calculate the combined displacement
            C(i, j, 1) = A(i, j, 1) + Bx_interp;
            C(i, j, 2) = A(i, j, 2) + By_interp;
        end
    end
end
