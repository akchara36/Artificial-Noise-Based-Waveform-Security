function tx = setup_pluto_tx(center_freq, sample_rate, gain)
% SETUP_PLUTO_TX Configures the ADALM-PLUTO transmitter
%
% Inputs:
%   center_freq - Carrier frequency in Hz
%   sample_rate - Sampling rate in Hz
%   gain        - Transmitter gain in dB (e.g., 0 to -89)
%
% Outputs:
%   tx - configured sdrtx object

    try
        tx = sdrtx('Pluto');
        tx.CenterFrequency = center_freq;
        tx.BasebandSampleRate = sample_rate;
        tx.Gain = gain;
        % tx.ShowAdvancedProperties = true; % Useful for debugging
    catch ME
        warning('Failed to initialize Pluto SDR TX: %s\nMake sure the SDR is connected and the Communications Toolbox Support Package for ADALM-PLUTO Radio is installed.', ME.message);
        tx = [];
    end
end
