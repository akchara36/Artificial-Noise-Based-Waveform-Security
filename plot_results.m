function plot_results(bob_eq, eve_eq, bob_ber, eve_ber, tx_signal, sample_rate)
% PLOT_RESULTS Displays constellation diagrams, BER, and Spectrum
%
% Inputs:
%   bob_eq - Equalized symbols at Bob
%   eve_eq - Symbols at Eve
%   bob_ber - Computed BER for Bob
%   eve_ber - Computed BER for Eve
%   tx_signal - The transmitted baseband signal
%   sample_rate - Sample rate for spectrum plotting

    figure('Name', 'Virtual MIMO Secure Communication Results', 'Position', [100, 100, 1000, 600]);

    % 1. Constellation for Bob
    subplot(2, 2, 1);
    plot(real(bob_eq), imag(bob_eq), 'b.', 'MarkerSize', 10);
    hold on;
    plot([-1 1], [0 0], 'r+', 'MarkerSize', 12, 'LineWidth', 2); % Ideal BPSK
    hold off;
    title(['Bob Constellation (Clean) - BER: ', num2str(bob_ber)]);
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on;
    axis([-2 2 -2 2]);

    % 2. Constellation for Eve
    subplot(2, 2, 2);
    plot(real(eve_eq), imag(eve_eq), 'r.', 'MarkerSize', 10);
    hold on;
    plot([-1 1], [0 0], 'k+', 'MarkerSize', 12, 'LineWidth', 2);
    hold off;
    title(['Eve Constellation (Degraded) - BER: ', num2str(eve_ber)]);
    xlabel('In-Phase');
    ylabel('Quadrature');
    grid on;
    axis([-3 3 -3 3]);

    % 3. Transmitted Signal Spectrum
    subplot(2, 2, [3, 4]);
    N = length(tx_signal);
    f = linspace(-sample_rate/2, sample_rate/2, N);
    spectrum = fftshift(fft(tx_signal));
    plot(f/1e6, 20*log10(abs(spectrum)/max(abs(spectrum))), 'b');
    title('Transmitted Signal Spectrum');
    xlabel('Frequency (MHz)');
    ylabel('Magnitude (dB)');
    grid on;
    axis tight;
    ylim([-60 5]);
end
