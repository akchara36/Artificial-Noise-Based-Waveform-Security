function [ber, num_errors] = compute_ber(tx_bits, rx_bits)
% COMPUTE_BER Calculates Bit Error Rate (BER)
%
% Inputs:
%   tx_bits - Original transmitted binary bits
%   rx_bits - Recovered binary bits at the receiver
%
% Outputs:
%   ber - Bit error rate
%   num_errors - Total number of bit errors

    % Ensure column vectors
    tx_bits = tx_bits(:);
    rx_bits = rx_bits(:);
    
    % Ensure same length
    len = min(length(tx_bits), length(rx_bits));
    tx_bits = tx_bits(1:len);
    rx_bits = rx_bits(1:len);

    % Calculate errors
    num_errors = sum(tx_bits ~= rx_bits);
    ber = num_errors / len;
end
