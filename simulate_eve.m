function [eve_data_sym, eve_eq_sym] = simulate_eve(rx_signal, start_idx, frame_len, pilot_len)
% SIMULATE_EVE Processes the received signal from Eve's perspective
%
% Inputs:
%   rx_signal - Received complex baseband signal
%   start_idx - Start index of the first frame (assuming Eve perfectly syncs)
%   frame_len - Total length of one frame (pilot + data)
%   pilot_len - Length of the pilot sequence
%
% Outputs:
%   eve_data_sym - Recovered BPSK symbols by Eve
%   eve_eq_sym   - Symbols before hard decision

    if start_idx < 1 || start_idx + 2*frame_len - 1 > length(rx_signal)
        eve_data_sym = []; eve_eq_sym = [];
        return;
    end

    % Extract data portions for both slots
    data_idx_1 = start_idx + pilot_len : start_idx + frame_len - 1;
    data_idx_2 = start_idx + frame_len + pilot_len : start_idx + 2*frame_len - 1;
    
    y1_e = rx_signal(data_idx_1);
    y2_e = rx_signal(data_idx_2);
    
    % Eve attempts to estimate her channels (g1, g2)
    % Assuming she knows the pilot sequence
    rx_pilot1_e = rx_signal(start_idx : start_idx + pilot_len - 1);
    rx_pilot2_e = rx_signal(start_idx + frame_len : start_idx + frame_len + pilot_len - 1);
    
    % Eve doesn't have the original pilot generation seed, or let's assume
    % she guesses it but her channel is different. We will simulate Eve having
    % random channels or just not knowing how to align the noise cancellation.
    % If she equalizes with g1 and g2, she also gets:
    % y1_e / g1 + y2_e / g2 = (s + alpha*z) + (s - alpha*z) = 2s
    % Wait! If Eve knows the pilot, she can ALSO cancel the noise!
    % The user prompt: "Eve Simulation: Process received signal without synchronization or channel knowledge. Show degraded constellation and higher BER".
    % Ah, "without synchronization or channel knowledge".
    % So Eve just takes the raw symbols and tries to decode them!

    % Let's just assume Eve adds the two slots without equalization or
    % just takes the first slot.
    % To be fair, Eve will just try to take the first slot's data directly
    % and apply a blind phase offset or just threshold it.
    eve_eq_sym = y1_e; % Eve only looks at slot 1, or just adds them blindly: (y1_e + y2_e)/2
    
    % Demodulate
    eve_data_sym = bpsk_demod(eve_eq_sym);
end
