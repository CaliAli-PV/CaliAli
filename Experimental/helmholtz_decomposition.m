function [phi, A] = helmholtz_decomposition(U, V)
    % Input: U, V - velocity field components
    % Output: phi - irrotational component, A - solenoidal component
    
    % Ensure the input matrices have the same size
    assert(all(size(U) == size(V)), 'Input matrices must have the same size.');

    % Calculate spatial derivatives
    [dU_dx, dU_dy] = gradient(U);
    [dV_dx, dV_dy] = gradient(V);

    % Calculate vorticity (curl) in 2D
    vorticity = dV_dx - dU_dy;

    % Poisson equation for irrotational component (phi)
    phi = poisson_solver_2d(-vorticity);

    % Calculate the solenoidal component (A)
    A = cat(3, U - dU_dx, V - dV_dy);
end

function laplacian_solution = poisson_solver_2d(rhs)
    % Solve the Poisson equation for laplacian_solution
    % with right-hand side (rhs) using the fft-based solver in 2D
    
    % Compute the size of the input
    [nx, ny] = size(rhs);
    
    % Wavenumbers in each direction
    kx = 2 * pi / nx * ifftshift(-(nx / 2):(nx / 2 - 1));
    ky = 2 * pi / ny * ifftshift(-(ny / 2):(ny / 2 - 1));

    % Meshgrid for the wavenumbers
    [KX, KY] = meshgrid(kx, ky);

    % Compute the Laplacian in frequency domain
    laplacian = -KX.^2 - KY.^2;

    % Avoid division by zero
    laplacian(1, 1) = 1;

    % Fourier transform of the right-hand side
    rhs_hat = fft2(rhs);

    % Solve for laplacian_solution in frequency domain
    laplacian_solution_hat = rhs_hat ./ laplacian';

    % Inverse Fourier transform to get the solution in spatial domain
    laplacian_solution = real(ifft2(laplacian_solution_hat));
end