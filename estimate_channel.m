function [h1, h2, start_idx] = estimate_channel(rx_signal, pilot_seq, frame_len)
% ESTIMATE_CHANNEL Synchronizes and estimates the channel for both slots
%
% Inputs:
%   rx_signal - Received complex baseband signal
%   pilot_seq - The known pilot sequence (BPSK symbols)
%   frame_len - Length of a single frame (pilot + data)
%
% Outputs:
%   h1 - Channel estimate for Slot 1
%   h2 - Channel estimate for Slot 2
%   start_idx - Index in rx_signal where Slot 1 begins

    corr_val = abs(conv(rx_signal, flipud(conj(pilot_seq)), 'valid'));
    [~, start_idx] = max(corr_val);
    
    % Ensure we have enough samples for both frames
    if start_idx < 1 || start_idx + 2*frame_len - 1 > length(rx_signal)
        warning('Valid frame not fully captured in the received signal buffer.');
        h1 = 0; h2 = 0;
        return;
    end
    
    pilot_len = length(pilot_seq);
    
    % Extract pilot part of Slot 1
    rx_pilot1 = rx_signal(start_idx : start_idx + pilot_len - 1);
    
    % Extract pilot part of Slot 2
    rx_pilot2 = rx_signal(start_idx + frame_len : start_idx + frame_len + pilot_len - 1);
    
    % Least Squares (LS) Channel Estimation
    % y = h*x + n -> h_est = y * x' / (x * x')
    % Since pilot_seq contains BPSK (-1, 1), x * x' = pilot_len
    h1 = (pilot_seq' * rx_pilot1) / pilot_len;
    h2 = (pilot_seq' * rx_pilot2) / pilot_len;
end
