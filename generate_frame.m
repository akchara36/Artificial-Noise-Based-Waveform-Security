function [frame, pilot_seq] = generate_frame(data_sym, pilot_len)
% GENERATE_FRAME Assembles pilot sequence and data into a structured frame
%
% Inputs:
%   data_sym - Vector of complex data symbols (e.g., BPSK)
%   pilot_len - Length of the pilot sequence to generate
%
% Outputs:
%   frame - Column vector of pilot prepended to data
%   pilot_seq - The generated pilot sequence

    % Generate a known pilot sequence (e.g., using a pseudo-random bit sequence)
    rng(42); % Fixed seed for the pilot so Tx and Rx both know it
    pilot_bits = randi([0 1], pilot_len, 1);
    pilot_seq = bpsk_mod(pilot_bits);
    
    % Ensure data is a column vector
    data_sym = data_sym(:);
    
    % Assemble frame
    frame = [pilot_seq; data_sym];
end
