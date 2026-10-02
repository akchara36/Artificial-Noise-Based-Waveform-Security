function z = generate_artificial_noise(len, alpha)
% GENERATE_ARTIFICIAL_NOISE Generates complex Gaussian noise
%
% Inputs:
%   len - Number of noise samples to generate
%   alpha - Scaling factor for the artificial noise
%
% Outputs:
%   z - Vector of scaled complex Gaussian noise

    % Generate complex Gaussian noise (zero mean, unit variance)
    noise_real = randn(len, 1);
    noise_imag = randn(len, 1);
    
    % Combine and scale by 1/sqrt(2) to maintain unit variance before alpha scaling
    z_normalized = (noise_real + 1i * noise_imag) / sqrt(2);
    
    % Scale by alpha
    z = alpha * z_normalized;
end
