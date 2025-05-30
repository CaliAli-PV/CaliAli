function S=create_similarity_matrix_2(m1,m2)
    % assume m1,m2 are (features × samples), possibly sparse
    n1 = sqrt(sum(m1.^2, 2));    % [n1×1]
    n2 = sqrt(sum(m2.^2, 2));    % [n2×1]

    % 2) raw dot-products
    D  = m1 * m2.';              % [n1×n2]

    % 3) normalize by outer product of norms
    S = D ./ (n1 * n2.');    
end


