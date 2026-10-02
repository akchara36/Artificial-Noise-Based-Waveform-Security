% main_virtual_mimo.m
% Real-Time Secure Communication using Virtual MIMO and Artificial Noise
% Implementation for ADALM-Pluto SDR

clc; clear; close all;

%% 1. Configuration Parameters
% System Parameters
num_data_bits = 1000;    % Number of data bits per frame
pilot_len = 100;         % Length of pilot sequence
alpha = 0.6;             % Artificial noise scaling factor (adjust to see Eve degradation)

% Hardware Parameters (Pluto SDR)
center_freq = 2.4e9;     % Center frequency: 2.4 GHz
sample_rate = 1e6;       % Sample rate: 1 MHz
tx_gain = 0;           % Transmitter gain (dB)
rx_gain = 20;            % Receiver gain (dB)

frame_len = pilot_len + num_data_bits;
% We transmit two frames (Virtual MIMO Slots)
tx_samples_per_burst = 2 * frame_len;

% Receiver captures more samples to ensure we catch the full burst
rx_capture_len = tx_samples_per_burst * 4; 

disp('--- Virtual MIMO Secure Communication Setup ---');
disp(['Artificial Noise Alpha: ', num2str(alpha)]);

%% 2. Signal Generation (Alice)
disp('Generating Baseband Signal...');
% Generate random data bits
tx_data_bits = randi([0 1], num_data_bits, 1);

% BPSK Modulation
tx_data_sym = bpsk_mod(tx_data_bits);

% Frame Generation (Pilot + Data)
[base_frame, pilot_seq] = generate_frame(tx_data_sym, pilot_len);

% Virtual MIMO Construction & Artificial Noise Injection
% x1 = frame + alpha*z, x2 = frame - alpha*z
[tx_signal, tx_noise] = construct_virtual_mimo(base_frame, alpha);

%% 3. Hardware Setup (Pluto SDR)
disp('Initializing Pluto SDRs...');
tx = setup_pluto_tx(center_freq, sample_rate, tx_gain);
rx = setup_pluto_rx(center_freq, sample_rate, rx_gain, rx_capture_len);

if isempty(tx) || isempty(rx)
    error('Could not initialize SDRs. Please check hardware connection.');
end

%% 4. Over-The-Air Transmission
disp('Transmitting over the air...');

% Ensure tx is configured properly, sometimes needs a warm-up transmission
tx(complex(zeros(length(tx_signal), 1)));
release(tx);
pause(0.5);

% Transmit the burst continuously
% Note: In a real system, you might transmit repeatedly.
transmitRepeat(tx, tx_signal);
disp('Transmitting continuous burst...');
pause(1); % Wait for steady state

disp('Receiving signal...');
% Receive samples from SDR
% Capture multiple frames to ensure we catch it
rx_signal = rx();

% Stop transmission after receiving
release(tx);
release(rx);
disp('Transmission stopped.');

%% 5. Receiver Processing (Bob)
disp('Bob is processing the received signal...');

% Channel Estimation & Synchronization
[h1_est, h2_est, start_idx] = estimate_channel(rx_signal, pilot_seq, frame_len);

if start_idx < 1 || start_idx + 2*frame_len - 1 > length(rx_signal)
    disp('Failed to synchronize frame. Cannot proceed with processing.');
    return;
end

disp(['Estimated Channel 1: ', num2str(h1_est)]);
disp(['Estimated Channel 2: ', num2str(h2_est)]);

% Equalization and Combining
[bob_data_sym, bob_eq_sym] = process_receiver_bob(rx_signal, start_idx, h1_est, h2_est, frame_len, pilot_len);

% Demodulate Bob's received bits
bob_rx_bits = bob_data_sym;

% Compute BER for Bob
[bob_ber, bob_errors] = compute_ber(tx_data_bits, bob_rx_bits);
disp(['Bob BER: ', num2str(bob_ber), ' (', num2str(bob_errors), ' errors)']);

%% 6. Receiver Processing (Eve)
disp('Eve is processing the received signal (No sync/channel info)...');

% Simulate Eve's attempt to decode the signal without knowing the channel
% or the exact noise structure to cancel it.
[eve_data_sym, eve_eq_sym] = simulate_eve(rx_signal, start_idx, frame_len, pilot_len);

% Compute BER for Eve
eve_rx_bits = eve_data_sym;
[eve_ber, eve_errors] = compute_ber(tx_data_bits, eve_rx_bits);
disp(['Eve BER: ', num2str(eve_ber), ' (', num2str(eve_errors), ' errors)']);

%% 7. Visualization
disp('Plotting results...');
plot_results(bob_eq_sym, eve_eq_sym, bob_ber, eve_ber, tx_signal, sample_rate);

disp('--- Complete ---');
