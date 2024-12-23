function plot_txsignal(filtered_preamble, cp_training_osifft, cp_data_osifft, txsignal, conf, num_packets)
    %PLOT_TXSIGNAL Plots the transmitted signal with sections highlighted
    %
    %   Inputs:
    %       filtered_preamble  : Preamble signal (time-domain)
    %       cp_training_osifft : Training symbol with cyclic prefix
    %       cp_data_osifft     : Data symbols with cyclic prefixes (time-domain)
    %       txsignal           : Full transmitted signal
    %       conf               : Configuration structure
    %       num_packets        : Number of OFDM data packets
    
    % Total length of each section
    preamble_len = length(filtered_preamble); % Preamble length
    training_len = length(cp_training_osifft); % Training symbol length (with CP)
    data_len = length(cp_data_osifft); % Total OFDM data length (with CPs)
    
    % Generate indices for each section
    preamble_end = preamble_len;
    cp_training_end = preamble_end + (1/3)*training_len;
    training_end = preamble_end + training_len;
    ofdm_start = training_end + 1;
    ofdm_end = ofdm_start + data_len - 1;

    % Ensure the total length of sections matches the transmitted signal
    total_len = preamble_len + training_len + data_len;
    assert(length(txsignal) == total_len, ...
           'Mismatch between txsignal length and computed sections.');
    
    % Time vector for plotting
    time_vector = (0:length(txsignal)-1) / conf.f_s; % Time in seconds
    
    % Plot the transmitted signal
    fontsize = 30;
    figure('Units', 'pixels', 'Position', [100, 100, 4000, 900]);
    plot(time_vector, txsignal, 'Color', [0.678, 0.478, 0.902, 1]); % Plot the transmitted signal
    xlabel('Time (s)', 'FontSize', fontsize);
    ylabel('Amplitude', 'FontSize', fontsize);
    title('Transmitted Signal', 'FontSize', fontsize);
    ax = gca;
    ax.FontSize = 20;
    hold on;
    
    % Highlight the preamble
    xline(preamble_end/conf.f_s, '--r', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
    text(preamble_end/conf.f_s, max(txsignal), 'Preamble', 'FontSize', fontsize, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', 'r');


    % Highlight the training symbol
    xline(cp_training_end/conf.f_s, ':k', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
    text(cp_training_end/conf.f_s, max(txsignal), 'CP', 'FontSize', fontsize, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', 'k');
    xline(training_end/conf.f_s, '--g', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
    text(training_end/conf.f_s, max(txsignal), 'OFDM training symbol', 'FontSize', fontsize, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', 'g');

    % Highlight each OFDM symbol
    for i = 1:num_packets
        % Calculate start and end indices for the current symbol
        symbol_start = training_end + 1 + (i-1) * training_len;
        cp_start = symbol_start;                            % Start of cyclic prefix
        cp_end = cp_start+(1/3)*training_len;               % End of cyclic prefix
        symbol_end = cp_start+training_len;                 % End of current OFDM symbol
        
        xline(cp_end/conf.f_s, ':k', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
        text(cp_end/conf.f_s, max(txsignal), 'CP', 'FontSize', fontsize, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', 'k');
        xline(symbol_end/conf.f_s, '--b', 'LineWidth', 2, 'LabelHorizontalAlignment', 'left');
        text(symbol_end/conf.f_s, max(txsignal), 'OFDM data symbol', 'FontSize', fontsize, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top', 'Color', 'b');

        
        
    end
    

    grid on;
    hold off;
end
