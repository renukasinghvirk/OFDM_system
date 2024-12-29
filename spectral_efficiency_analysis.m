function spectral_efficiency_analysis(conf, measured_delay_spread)
    % Inputs:
    %   conf - Configuration structure containing OFDM parameters.
    %          Required fields: modulation_order, spacing, N_subcarriers.
    %   measured_delay_spread - Measured delay spread of the channel (seconds).
    %
    % Outputs:
    %   None: Prints current and reduced spectral efficiency and CP overhead.

    % Parameters from the configuration
    M = conf.modulation_order; % Bits per symbol (2 for QPSK)
    f_spacing = conf.spacing; % Subcarrier spacing (Hz)
    N_subcarriers = conf.N_subcarriers; % Number of subcarriers

    % Calculate useful OFDM symbol duration
    useful_symbol_length = 1 / f_spacing; % Time duration of one OFDM symbol without CP

    % Current CP length 
    current_cp_length = useful_symbol_length*conf.cp; % CP duration
    beta_current = current_cp_length / (current_cp_length + useful_symbol_length);

    % Spectral efficiency with current CP
    eta_current = M * (1 - beta_current);

    % Reduced CP based on measured delay spread
    reduced_cp_length = measured_delay_spread; % Set CP length to delay spread
    if reduced_cp_length > useful_symbol_length
        warning('Measured delay spread exceeds useful symbol duration. Adjust CP length.');
        reduced_cp_length = useful_symbol_length; % Cap CP length to the symbol length
    end
    beta_reduced = reduced_cp_length / (reduced_cp_length + useful_symbol_length);
    eta_reduced = M * (1 - beta_reduced);

    % Display results
    fprintf('Current CP Overhead: %.2f%%\n', beta_current * 100);
    fprintf('Reduced CP Overhead: %.2f%%\n', beta_reduced * 100);
    fprintf('Spectral Efficiency (Current CP): %.2f bits/s/Hz\n', eta_current);
    fprintf('Spectral Efficiency (Reduced CP): %.2f bits/s/Hz\n', eta_reduced);
    fprintf('Spectral Efficiency Gain: %.2f%%\n', ((eta_reduced - eta_current) / eta_current) * 100);
end
