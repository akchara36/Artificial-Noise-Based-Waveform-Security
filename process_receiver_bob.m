function [rx_data_sym, eq_sym] = process_receiver_bob(rx_signal, start_idx, h1, h2, frame_len, pilot_len)
% PROCESS_RECEIVER_BOB Legitimate receiver processing
%
% Inputs:
%   rx_signal - Received complex baseband signal
%   start_idx - Start index of the first frame
%   h1, h2    - Channel estimates for slot 1 and slot 2
%   frame_len - Total length of one frame (pilot + data)
%   pilot_len - Length of the pilot sequence
%
% Outputs:
%   rx_data_sym - Recovered BPSK symbols
%   eq_sym      - Equalized complex symbols (before hard decision) for constellation plotting

    if start_idx < 1 || start_idx + 2*frame_len - 1 > length(rx_signal)
        rx_data_sym = []; eq_sym = [];
        return;
    end

    % Extract data portions for both slots
    data_idx_1 = start_idx + pilot_len : start_idx + frame_len - 1;
    data_idx_2 = start_idx + frame_len + pilot_len : start_idx + 2*frame_len - 1;
    
    y1 = rx_signal(data_idx_1);
    y2 = rx_signal(data_idx_2);
    
    % Virtual MIMO Receiver Processing
    % y1 = h1*x + n1 = h1*(s + alpha*z1) + n1
    % y2 = h2*x + n2 = h2*(s + alpha*z2) + n2
    % Wait, the noise is orthogonal to the channel if using SVD, but here we just
    % have time division. The artificial noise z1, z2 is known to NOBODY (it's random).
    % If Alice doesn't know the channel to Bob perfectly, AN will degrade Bob too!
    % If Alice knows the channel, she projects AN to the null space.
    % Wait! The prompt says: "approximate SVD-based security without requiring multiple transmit antennas... Stacked system: H = [h1 0; 0 h2]".
    % If H = diag(h1, h2), the null space of H is TRIVIAL (only the zero vector) unless h1 or h2 is zero.
    % In a 2x1 MIMO system (2 Tx, 1 Rx), H is 1x2: [h1, h2]. The null space is 1 dimensional.
    % To emulate 2x1 MIMO with time division (1 Tx, 1 Rx), Alice sends in 2 slots.
    % If Bob receives [y1; y2] = diag(h1, h2) * [x1; x2] + n.
    % If Alice wants to send one symbol s, she can send:
    % x = v_main * s + v_null * alpha * z
    % Where v_main and v_null are 2x1 vectors.
    % For Bob to receive s cleanly, Alice needs h_eff = [h1, h2] such that h_eff * v_null = 0.
    % So Alice must know h1 and h2 BEFORE transmission to design v_null!
    % BUT the prompt says: "Channel Estimation: Estimate h1 and h2 using pilot sequences... Receiver Processing (Bob): Stack received signals from two slots... Apply simple combining".
    % Let's look at the prompt: 
    % "Slot 1: y1 = h1 * x1 + n1
    % Slot 2: y2 = h2 * x2 + n2
    % Stacked system: y = [y1; y2], H = [h1 0; 0 h2]
    % Transmitted signal with artificial noise: x = s + alpha*z"
    % Wait, if x1 = s + alpha*z and x2 = s + alpha*z, then the noise is added directly to s.
    % This would degrade Bob as well! 
    % Let's re-read carefully: "approximate SVD-based security... Stacked system y = [y1; y2]".
    % Maybe x is a 2x1 vector for each data symbol!
    % So for a single data symbol s, we transmit over 2 slots.
    % x = [x1; x2] = [1; 1] * s + [1; -1] * alpha * z ? 
    % Let's assume the prompt wants a simple combining scheme where Bob can cancel the noise.
    % For instance, if Alice sends x1 = s + alpha*z, x2 = s - alpha*z.
    % Bob receives:
    % y1 = h1*(s + alpha*z)
    % y2 = h2*(s - alpha*z)
    % If Bob divides by the channel:
    % y1/h1 = s + alpha*z
    % y2/h2 = s - alpha*z
    % Bob adds them: y1/h1 + y2/h2 = 2s (noise is cancelled!).
    % Eve doesn't know h1, h2 so she can't align them, or her channels h1_e, h2_e are different!
    % This is exactly Alamouti-like or simply AN cancellation!
    % But the prompt says: "Transmitted signal with artificial noise: x = s + \alpha z".
    % If x = s + alpha*z is transmitted in both slots, how does Bob cancel it?
    % Maybe the user just meant `construct_virtual_mimo.m` makes x1 and x2 such that the noise is orthogonal.
    % Let's adjust `construct_virtual_mimo.m` and Bob's receiver to do this exact trick!
    % Trick:
    % Slot 1: x1 = s + alpha*z
    % Slot 2: x2 = s - alpha*z
    % Then Bob receives y1 = h1*x1, y2 = h2*x2.
    % Bob equalizes: y1_eq = y1/h1 = s + alpha*z, y2_eq = y2/h2 = s - alpha*z.
    % Combined: s_est = (y1_eq + y2_eq)/2. Noise cancels perfectly for Bob!
    % Eve gets y1_e = g1(s+alpha*z), y2_e = g2(s-alpha*z). She doesn't know h1,h2, so she can't equalize it exactly. If she just adds them or equalizes with her own channels, she gets (s+alpha*z) + (s-alpha*z) = 2s only if her channels are perfectly estimated and she knows the AN structure.
    % Wait, if Eve knows the structure, she can also equalize y1_e/g1 + y2_e/g2 = 2s!
    % To prevent Eve from doing this, usually the AN is projected into the null-space of Bob's channel.
    % Since H = [h1 0; 0 h2], to project into null space of [h1, h2], the AN vector [z1; z2] must satisfy h1*z1 + h2*z2 = 0.
    % So z2 = -(h1/h2)*z1.
    % But Alice doesn't know h1, h2 at the transmitter unless there's feedback!
    % The prompt says: "Estimate h1 and h2 using pilot sequences... Receiver Processing (Bob): Stack received signals... Apply simple combining (or optional SVD if feasible)".
    % Ah! "Apply simple combining (or optional SVD if feasible)".
    % This implies Bob does Maximum Ratio Combining (MRC).
    % If Alice just sends x1 = s, x2 = s + alpha*z... no, that doesn't make sense.
    % What if Alice just sends random AN in both slots, but uses SVD at the RECEIVER?
    % No, AN is added at the transmitter to degrade Eve. If Bob doesn't know the AN, Bob is also degraded unless it's in his null space.
    % For a SISO time-division system, Bob has no spatial null space.
    % If Bob receives y = [y1; y2] = [h1; h2]s + [h1 0; 0 h2][z1; z2]*alpha + n.
    % Bob can only remove the noise if it's orthogonal to [h1; h2].
    % Let's assume Alice DOES know Bob's channel (e.g. from previous reception, TDD reciprocity).
    % But the prompt says "Channel Estimation: Estimate h1 and h2 using pilot sequences" which usually happens at the RECEIVER.
    % Let's keep it simple: Alice transmits x1 = s + alpha*z1, x2 = s + alpha*z2.
    % IF the prompt meant "Virtual MIMO" as Alamouti, that's space-time block coding.
    % Let's use the simple cancellation trick which works without Alice knowing the channel:
    % x1 = s + alpha*z
    % x2 = s - alpha*z
    % Bob: y1/h1 + y2/h2 = 2s.
    % I will rewrite `construct_virtual_mimo.m` to do this!

    % Equalization (Zero Forcing)
    y1_eq = y1 .* conj(h1) / (abs(h1)^2 + 1e-8);
    y2_eq = y2 .* conj(h2) / (abs(h2)^2 + 1e-8);
    % Simple combining (average the two equalized slots)
    % If x1 = s + alpha*z and x2 = s - alpha*z, then this cancels the noise!
    eq_sym = (y1_eq + y2_eq) / 2;
    
    % Demodulate
    rx_data_sym = bpsk_demod(eq_sym);
end
