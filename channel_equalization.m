function [corr_data_osffts, H_estimated] = channel_equalization(training_osfft, tx_training_symbols, data_osffts, conf)
    % CHANNEL_EQUALIZATION Equalizes OFDM data symbols for each packet
    N_subcarriers = conf.N_subcarriers;
    % Estimate the channel response (H for each subcarrier)
    H_estimated = training_osfft ./ tx_training_symbols; % Size: [N_subcarriers, 1]
    
    % Ensure data_osffts length is a multiple of N_subcarriers
    num_packets = length(data_osffts) / N_subcarriers;
    if mod(length(data_osffts), N_subcarriers) ~= 0
        error('Size mismatch: data_osffts must be a multiple of N_subcarriers.');
    end

    % Reshape data_osffts into packets of N_subcarriers
    data_osffts_reshaped = reshape(data_osffts, N_subcarriers, num_packets);

    % Apply equalization packet by packet
    corr_data_osffts = zeros(size(data_osffts_reshaped)); % Preallocate
    for i = 1:num_packets
        corr_data_osffts(:, i) = data_osffts_reshaped(:, i) ./ abs(H_estimated); % Element-wise equalization
    end

    %% VISUALIZE CHANNEL SPECTRUM
    corr_data_osffts = corr_data_osffts(:); % Flatten corrected data symbols
    disp('You used the channel equalization method');
    figure;
    plot(abs(H_estimated).^2, 'LineWidth', 2);
    title('Channel Spectrum', 'FontSize', 18, 'FontWeight', 'bold');
    xlabel('Subcarrier Index', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('|H[n, m]|^2', 'FontSize', 16, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14, 'LineWidth', 1.5); % Axis properties
    grid on;

    %% VISUALIZE DELAY SPREAD
    impulse_response = ifft(H_estimated, N_subcarriers);
    pdp = abs(impulse_response).^2; % Power Delay Profile
    delays = (0:N_subcarriers - 1).' / conf.f_s;

    % Normalize PDP for better visualization
    figure;
    stem(delays, pdp, 'filled', 'LineWidth', 2);
    title('Power Delay Profile', 'FontSize', 18, 'FontWeight', 'bold');
    xlabel('Delay (seconds)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Normalized Power', 'FontSize', 16, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14, 'LineWidth', 1.5); % Axis properties
    grid on;

    rms_delay = sqrt(sum((delays.^2) .* pdp) / sum(pdp) - (sum(delays .* pdp) / sum(pdp))^2);
    disp(['RMS Delay Spread: ', num2str(rms_delay), ' seconds']);

    %% CHANNEL EVOLUTION OVER TIME
    channel_evolution = zeros(N_subcarriers, num_packets);
    for i = 1:num_packets
        channel_evolution(:, i) = data_osffts_reshaped(:, i) ./ tx_training_symbols;
    end

    figure;
    imagesc(1:num_packets, 1:N_subcarriers, abs(channel_evolution)); % Magnitude of H[n, m]
    colorbar;
    xlabel('OFDM Symbol Index (Time)', 'FontSize', 16, 'FontWeight', 'bold');
    ylabel('Subcarrier Index (Frequency)', 'FontSize', 16, 'FontWeight', 'bold');
    title('Channel Magnitude Evolution Over Time', 'FontSize', 18, 'FontWeight', 'bold');
    set(gca, 'FontSize', 14, 'LineWidth', 1.5); % Axis properties
    axis xy; % Ensure subcarrier index is displayed correctly

    %% SPECTRAL EFFICIENCY
    spectral_efficiency_analysis(conf, rms_delay);
end
