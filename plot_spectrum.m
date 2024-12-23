function plot_spectrum(signal, fs, title_str)
    %PLOT_SPECTRUM Visualizes the spectrum of a given signal
    %   Inputs:
    %       signal    : The input signal (time domain)
    %       fs        : Sampling frequency in Hz
    %       title_str : Title of the plot (optional)
    %
    %   Outputs:
    %       A plot showing the magnitude spectrum of the signal
    
    % Length of the signal
    N = length(signal);

    % Compute the FFT
    fft_signal = fft(signal);

    % Compute the frequency axis (centered around zero)
    f = (-N/2:N/2-1) * (fs / N); % Frequency in Hz

    % Shift the FFT result to center zero frequency
    fft_shifted = fftshift(fft_signal);

    % Compute the magnitude spectrum
    magnitude_spectrum = abs(fft_shifted);

    % Plot the spectrum
    fontsize = 30;
    figure('Units', 'pixels', 'Position', [100, 100, 800, 800]);
    plot(f, magnitude_spectrum, 'LineWidth', 1.5, 'Color', [0.28, 0.2, 0.9, 1]);
    xlabel('Frequency (Hz)', 'FontSize', fontsize);
    ylabel('Magnitude', 'FontSize', fontsize);
    xlim([-10000 10000]);
    ax = gca; % Get current axes
    ax.FontSize = 20; % Set font size for axis tick labels
    
    % Add title if provided
    if nargin > 2
        title(title_str, 'FontSize', fontsize);
    else
        title('Spectrum of the Signal', 'FontSize', fontsize);
    end

    grid on;
end
