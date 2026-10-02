function rx_bits = bpsk_demod(rx_sym)
% BPSK_DEMOD Demodulates received BPSK symbols to binary data
%
% Inputs:
%   rx_sym - Vector of received complex symbols
%
% Outputs:
%   rx_bits - Vector of recovered binary bits (0s and 1s)
%
% Thresholding: real(rx_sym) > 0 -> 1, else 0

    % Extract real part and apply threshold at 0
    rx_bits = double(real(rx_sym) > 0);
end
