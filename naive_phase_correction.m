function [data_osffts, corr_data_osffts] = naive_phase_correction(training_osfft, tx_training_symbols, rxsignal_bb, conf, training_end, cp_len, ofdm_symbol_len)
%   NAIVE_PHASE_CORRECTION Processes OFDM signals with phase correction only
%   This function computes phase offsets between training symbols,
%   isolates data OFDM signals, and applies phase correction (without magnitude correction).
%   Raw symbols are also normalized to the unit circle.
%
% Inputs:
%   training_osfft   - Received training symbols in frequency domain
%   tx_training_symbols - Transmitted training symbols
%   rxsignal_bb      - Baseband received signal
%   conf             - Configuration structure
%   training_end     - End index of the training OFDM signal
%   cp_len           - Length of the cyclic prefix
%   ofdm_symbol_len  - Length of the full OFDM symbol (including cyclic prefix)
%
% Outputs:
%   data_osffts      - Raw data symbols in frequency domain (normalized)
%   corr_data_osffts - Phase-corrected data symbols (normalized)

    % Preallocate arrays for angles and offsets
    rx_training_angles = zeros(length(training_osfft), 1);
    tx_training_angles = zeros(length(training_osfft), 1);
    offset_angles = zeros(length(training_osfft), 1); 

    % Compute phase offsets
    for i = 1:length(training_osfft)
        rx_training_angles(i) = mod(angle(training_osfft(i)), 2*pi); % Compute received angle
        tx_training_angles(i) = mod(angle(tx_training_symbols(i)), 2*pi); % Compute transmitted angle
        offset_angles(i) = rx_training_angles(i) - tx_training_angles(i); % Compute phase offset
    end
    

    % Isolate data OFDM signals
    num_packets = conf.nbits / (2 * conf.N_subcarriers);
    data_osffts = [];
    corr_data_osffts = [];

    for i = 1:num_packets
        % Extract data signal for the current packet
        data_start = training_end + i * cp_len + (i - 1) * ofdm_symbol_len + 1;
        data_end = data_start + ofdm_symbol_len - 1;
        data_signal = rxsignal_bb(data_start:data_end);

        % Transform to frequency domain
        packet_osfft = osfft(data_signal, conf.os_factor);

        % Normalize raw symbols to the unit circle
        normalized_packet = packet_osfft ./ abs(packet_osfft);

        % Save normalized raw symbols
        data_osffts = [data_osffts; normalized_packet];

        % Apply phase correction
        corrected_packet = normalized_packet .* exp(-1j * offset_angles);

        % Save corrected symbols (already normalized)
        corr_data_osffts = [corr_data_osffts; corrected_packet];
    end

    disp('You used the naive phase correction method');
end
