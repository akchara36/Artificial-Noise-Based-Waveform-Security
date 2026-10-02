function tx_sym = bpsk_mod(tx_bits)
% BPSK_MOD Maps binary data to BPSK symbols
%
% Inputs:
%   tx_bits - Vector of binary bits (0s and 1s)
%
% Outputs:
%   tx_sym - Vector of BPSK symbols (-1 and +1)
%
% BPSK Mapping: 0 -> -1, 1 -> +1

    % Convert 0s and 1s to -1s and +1s
    tx_sym = 2*tx_bits - 1;
    
    % Ensure complex double type as it's common for SDR processing
    tx_sym = complex(tx_sym, 0);
end
