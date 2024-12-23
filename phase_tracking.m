function [payload_data] = phase_tracking(corr_data_osffts, training_osfft, tx_training_symbols, conf)
%PHASE_TRACKING Performs phase tracking for each subcarrier and packet
%
% Inputs:
%   corr_data_osffts    - Frequency-domain received data symbols (corrected for magnitude)
%   training_osfft      - Frequency-domain received training symbols
%   tx_training_symbols - Transmitted training symbols (known)
%   conf                - Configuration structure
%
% Outputs:
%   payload_data        - Phase-corrected data symbols

    % Number of subcarriers and packets
    N_subcarriers = conf.N_subcarriers;
    num_packets = conf.nbits / (2 * N_subcarriers); % Number of packets
    
    % Initialize the corrected payload data
    payload_data = zeros(N_subcarriers, num_packets); % Size: subcarriers x packets
    
    % Compute phase offsets for each subcarrier using the training symbol
    rx_training_angles = zeros(length(training_osfft), 1);
    tx_training_angles = zeros(length(training_osfft), 1);
    offset_angles = zeros(length(training_osfft), 1); 
    for i = 1:length(training_osfft)
        rx_training_angles(i) = mod(angle(training_osfft(i)), 2*pi); % Compute received angle
        tx_training_angles(i) = mod(angle(tx_training_symbols(i)), 2*pi); % Compute transmitted angle
        offset_angles(i) = rx_training_angles(i) - tx_training_angles(i); % Compute phase offset
    end

   % phase_of_peak = mod(angle(training_osfft ./ tx_training_symbols), 2*pi);
    phase_of_peak = offset_angles;
    % Reshape the received data symbols into subcarriers x packets
    corr_data_osffts = reshape(corr_data_osffts, N_subcarriers, num_packets); % 256 * 16

    % Process each subcarrier independently
    for n = 1:N_subcarriers
        % Extract the symbols for the current subcarrier across all packets
        subcarrier_data = corr_data_osffts(n, :); % 1 * 16

        % Apply phase estimation and correction for this subcarrier
        corrected_subcarrier_data = phase_estimator(subcarrier_data, phase_of_peak(n), num_packets, conf);

        % Transpose corrected_subcarrier_data to ensure row format
        payload_data(n, :) = corrected_subcarrier_data.'; % 1 * 16

    end
    
    % Reshape the corrected payload data back to a single vector
    payload_data = payload_data(:); % 256 * 16


    disp('Phase tracking applied using training symbol estimates.');
end
