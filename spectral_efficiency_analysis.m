function spectral_efficiency_analysis(conf, measured_delay_spread)
    % Inputs:
    %   conf - Configuration structure containing OFDM parameters.
    %   measured_delay_spread - Measured delay spread of the channel (seconds).

    % Parameters from the configuration
    M = conf.modulation_order; % Bits per symbol (e.g., 2 for QPSK)
    f_spacing = conf.spacing; % Subcarrier spacing (Hz)
    N_subcarriers = conf.N_subcarriers; % Number of subcarriers
 
    % Useful symbol length
    useful_symbol_length = 1 / f_spacing; % Time duration of one OFDM symbol without CP

    % Current CP overhead
    current_cp_length = useful_symbol_length / 2; % Assume 50% overhead for CP
    beta = current_cp_length / (current_cp_length + useful_symbol_length);

    % Spectral efficiency with current CP
    eta_current = M * (1 - beta);

    % Reduced CP based on measured delay spread
    reduced_cp_length = measured_delay_spread; % Set CP length to delay spread
    beta_reduced = reduced_cp_length / (reduced_cp_length + useful_symbol_length);
    eta_reduced = M * (1 - beta_reduced);

    % Display results
    fprintf('Current CP Overhead: %.2f%%\n', beta * 100);
    fprintf('Reduced CP Overhead: %.2f%%\n', beta_reduced * 100);
    fprintf('Spectral Efficiency (Current CP): %.2f bits/s/Hz\n', eta_current);
    fprintf('Spectral Efficiency (Reduced CP): %.2f bits/s/Hz\n', eta_reduced);
    fprintf('Spectral Efficiency Gain: %.2f%%\n', ((eta_reduced - eta_current) / eta_current) * 100);
end
