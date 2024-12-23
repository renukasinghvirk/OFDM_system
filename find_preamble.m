function [beginning_of_data, phase_of_peak, magnitude_of_peak] = find_preamble(rx_signal, conf)
    % note that this function only works for noisy signal !!!
    % Frame synchronizer.
    % rx_signal is the noisy received signal, and L is the oversampling factor 
    % (L=1 in chapter 2, L=4 in all later chapters).
    % The returned value is the index of the first data symbol in rx_signal.

    if (rx_signal(1) == 0)
        warning('Signal seems to be noise-free. The frame synchronizer will not work in this case.');
    end

    detection_threshold = 15; % Threshold for peak detection
    frame_sync_length = conf.npreamble; % Length of the frame synchronization sequence
    magnitude_of_peak = 0; % Initialize peak magnitude

    % Generate the frame synchronization sequence and map it to BPSK: 0 -> +1, 1 -> -1
    frame_sync_sequence = 1 - 2 * lfsr_framesync(frame_sync_length);

    % Variables for peak detection in oversampled signals
    current_peak_value = 0;
    L = conf.os_factor_preamble; % Oversampling factor
    samples_after_threshold = L;

    % Initialize variables for tracking test statistic T
    T_values = zeros(1, length(rx_signal)); % Preallocate array for T values
    T_indices = (L * frame_sync_length + 1):length(rx_signal); % Indices where T is computed

    % Loop through the received signal to find the synchronization sequence
    for i = T_indices
        % Extract the relevant part of the received signal
        r = rx_signal(i - L * frame_sync_length : L : i - L);
        
        % Compute the correlation
        c = frame_sync_sequence' * r;
        
        % Compute the test statistic T
        T = abs(c)^2 / abs(r' * r);
        T_values(i) = T; % Store T value for visualization

        % Check if the test statistic exceeds the detection threshold
        if (T > detection_threshold || samples_after_threshold < L)
            samples_after_threshold = samples_after_threshold - 1;
            
            if (T > current_peak_value)
                beginning_of_data = i;
                phase_of_peak = mod(angle(c), 2*pi);
                magnitude_of_peak = abs(c) / frame_sync_length;
                current_peak_value = T;
            end
            
            % Stop searching if we've processed enough samples after the threshold
            if (samples_after_threshold == 0)
                break;
            end
        end
    end

    % Plot T values to justify the threshold choice
    fontsize=30;
    figure('Units', 'pixels', 'Position', [100, 100, 800, 400]);
    plot(T_indices, T_values(T_indices), 'b', 'LineWidth', 1.5); % Plot test statistic T values
    hold on;
    yline(detection_threshold, 'r--', 'LineWidth', 1.5); % Plot the threshold line
    text(T_indices(end), detection_threshold, 'Threshold', 'FontSize', fontsize/2, 'HorizontalAlignment', 'right', 'VerticalAlignment', 'bottom', 'Color', 'r');
    legend('Test Statistic T', 'Detection Threshold', 'Location', 'Best');
    title('Test Statistic T vs. Sample Index', 'FontSize', fontsize);
    xlabel('Sample Index', 'FontSize', fontsize);
    ylabel('Test Statistic Magnitude', 'FontSize', fontsize);
    ax = gca; % Get current axes
    ax.FontSize = 20; % Set font size for axis tick labels
    grid on;

    % If no synchronization sequence is found, raise an error
    if ~exist('beginning_of_data', 'var')
        error('No synchronization sequence found.');
    end

    return;

end
