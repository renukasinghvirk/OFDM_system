function [txsignal conf] = tx(txbits,conf,k)
% Digital Transmitter consisting of:
    %       - 
    %       - 
    %       -  
    %
    %   txbits  : Information bits
    %   conf    : Universal configuration structure
    %   k       : Frame index
    
    %% BPSK Preamble
    preamble_bits = lfsr_framesync(conf.npreamble);  % 50-bit preamble
    preamble_symbols = -2 * (preamble_bits) + 1;  % BPSK mapping  
    preamble_up = upsample(preamble_symbols, conf.os_factor_preamble);
    preamble_up = preamble_up(:); % Force column vector
    
    %% BPSK Training OFDM
    training_bits = lfsr_framesync(conf.N_subcarriers); % 256-bit training
    training_symbols = -2 * (training_bits) + 1;  % BPSK mapping   

    %plot_constellations(training_symbols, 'BPSK training symbols');

    %% OFDM training through osIFFT
    training_osifft = osifft(training_symbols, conf.os_factor);
    reverted_symbols = osfft(training_osifft, conf.os_factor);
    %plot_constellations(reverted_symbols, 'Reverted BPSK training symbols');
    % add cyclic prefix
    % Calculate the index for the second half
    mid_idx = ceil(length(training_osifft) / 2)+1; % Find the midpoint of training_osifft
    
    % Select the second half as the cyclic prefix
    cyclic_prefix_training = training_osifft(mid_idx:end);
    
    % Append the cyclic prefix to the beginning of the OFDM symbol
    cp_training_osifft = [cyclic_prefix_training; training_osifft];

    %% Normalize

    cp_training_osifft = cp_training_osifft / sqrt(mean(abs(cp_training_osifft).^2));

    %% QPSK Mapping OFDM
    bits = 2 * (txbits - 0.5); % Convert bits to [-1, 1]
    bits2 = reshape(bits, 2, []);
    real_p = ((bits2(1,:) > 0) - 0.5) * sqrt(2);
    imag_p = ((bits2(2,:) > 0) - 0.5) * sqrt(2);
    symbols = real_p + 1i * imag_p;

    plot_constellations(symbols, 'QPSK data symbols');


    %% Check data size is multiple of N (256) => add padding, mention for presentation

    %% OFDM data through osIFFT
    num_packets = length(symbols)/conf.N_subcarriers;
    cp_data_osifft = [];

    for i=1:num_packets
        packet_osifft = osifft(symbols((i-1)*256+1:i*256), conf.os_factor);
        % add 50% of packet_osifft as cyclic prefix
        mid_idx = ceil(length(packet_osifft) / 2)+1;
        cyclic_prefix = packet_osifft(mid_idx:end);
        packet_osifft = [cyclic_prefix; packet_osifft];
        % P/S 
        cp_data_osifft = [cp_data_osifft; packet_osifft];
    end
    
    %% normaliser

    cp_data_osifft = cp_data_osifft/sqrt(mean(abs(cp_data_osifft).^2));

    %% Pulse shape preamble
    pulse = rrc(conf.os_factor_preamble, 0.22, 2000); % Root Raised Cosine filter for preamble
    filtered_preamble = conv(preamble_up, pulse.', 'full');

    %% crop preamble convolutions 
    filtered_preamble = filtered_preamble(1+(length(pulse)-1)/2:end-(length(pulse)-1)/2);
    %% normaliser preamble
    
    filtered_preamble = filtered_preamble / sqrt(mean(abs(filtered_preamble).^2));
    
    %% Combine preamble, OFDM training, OFDM data
    tx_signal = [filtered_preamble; cp_training_osifft(:); cp_data_osifft(:)];

    %% Up-conversion
    % Time vector
    time = (0:length(tx_signal)-1).' / conf.f_s;

    % Generate the complex exponential carrier
    % SHOULD WE TAKE fc/fs * n?
    complex_carrier = exp(1i * 2 * pi * conf.f_c * time);

    % Perform up-conversion
    upconverted_signal = tx_signal .* complex_carrier;

    % Take the real part of the upconverted signal
    txsignal = real(upconverted_signal);
%     disp('Txsignal: ');
%     disp(size(txsignal));
    % The code below is to ensure the relative lengths of the different
    % segments are coherent
   % assert(length(cp_training_osifft)==(length(cp_data_osifft)/num_packets));
%     disp('Preamble signal: ');
%     disp(size(filtered_preamble));
%     disp('Training signal with CP: ');
%     disp(size(cp_training_osifft));
%     disp('Data signal with CP: ');
%     disp(size(cp_data_osifft));



    % Plot txsignal
    %plot_txsignal(filtered_preamble, cp_training_osifft, cp_data_osifft, txsignal, conf, num_packets);
    plot_spectrum(txsignal, conf.f_s, 'Spectrum of the transmitted signal')


end