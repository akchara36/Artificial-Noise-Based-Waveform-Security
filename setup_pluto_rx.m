function rx = setup_pluto_rx(center_freq, sample_rate, gain, frame_size)
% SETUP_PLUTO_RX Configures the ADALM-PLUTO receiver
%
% Inputs:
%   center_freq - Carrier frequency in Hz
%   sample_rate - Sampling rate in Hz
%   gain        - Receiver gain in dB
%   frame_size  - Number of samples per frame to output
%
% Outputs:
%   rx - configured sdrrx object

    try
        rx = sdrrx('Pluto');
        rx.CenterFrequency = center_freq;
        rx.BasebandSampleRate = sample_rate;
        rx.GainSource = 'Manual';
        rx.Gain = gain;
        rx.OutputDataType = 'double';
        rx.SamplesPerFrame = frame_size;
    catch ME
        warning('Failed to initialize Pluto SDR RX: %s\nMake sure the SDR is connected and the Communications Toolbox Support Package for ADALM-PLUTO Radio is installed.', ME.message);
        rx = [];
    end
end
