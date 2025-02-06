function S=create_similarity_matrix_2(m1,m2)

% SA_t1=create_similarity_matrix_2(t1_A,All_A);
% SC_t1=create_similarity_matrix_2(t1_C,All_C(:,1:1000));

m1 = full(m1)';
m2 = full(m2)';

% Pre-calculate norms of m2 columns for efficiency
m2_norms = vecnorm(m2);

S = zeros(size(m1, 2), size(m2, 2)); % Pre-allocate S as a numeric array

parfor i = 1:size(m1, 2)
    A = m1(:, i); % Get the i-th column of m1
    A_norm = norm(A); % Calculate the norm of the i-th column of m1
    
    % Calculate cosine similarity (corrected for parfor)
    tempS = zeros(1, size(m2, 2)); % Temporary variable for inner loop
    for j = 1:size(m2, 2)
        tempS(j) = (dot(A, m2(:, j)) ./ (A_norm .* m2_norms(j))); 
    end
    S(i, :) = tempS; % Assign the result to the sliced variable
end

end


