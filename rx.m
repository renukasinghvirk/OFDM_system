function [rxbits conf] = rx(rxsignal,conf,k)
% Digital Receiver
%   
%   Inputs
%
%   rxsignal    : received signal
%   conf        : configuration structure
%   k           : frame index
%
%   Outputs
%
%   rxbits      : received bits
%   conf        : configuration structure
%

%% VISUALIZE RX SIGNAL
% % Time vector for plotting
time_vector = (0:length(rxsignal)-1) / conf.f_s; % Time in seconds
    
%Plot the received signal
%time domain
if conf.plot
    fontsize = 30;
    figure('Units', 'pixels', 'Position', [100, 100, 4000, 200]);
    plot(time_vector, rxsignal, 'Color', [0.678, 0.478, 0.902, 1]); % Plot the transmitted signal
    xlabel('Time (s)', 'FontSize', fontsize);
    ylabel('Amplitude', 'FontSize', fontsize);
    title('Received Signal', 'FontSize', fontsize);
    ax = gca;
    ax.FontSize = 20;

    %spectrum
    plot_spectrum(rxsignal, conf.f_s, 'Spectrum of the received signal')
end


%% Down-conversion

% Time vector
time = (0:length(rxsignal)-1).' / conf.f_s;
    
% Generate the complex exponential carrier
complex_carrier = exp(1i * 2 * pi * -conf.f_c * time); 
    
% Perform down-conversion
downconverted_signal = rxsignal .* complex_carrier;
if conf.plot
    plot_spectrum(downconverted_signal, conf.f_s, 'Spectrum of the downconverted Rx signal');
end


%% Lowpass the signal 
rxsignal_bb = ofdmlowpass(downconverted_signal, conf, conf.f_c); 
if conf.plot
    plot_spectrum(rxsignal_bb, conf.f_s, 'Spectrum of the lowpass, downconverted Rx signal');
end

%% Find preamble 
[start_idx,phase_of_peak,~] = find_preamble(rxsignal_bb, conf);

%% Isolate training OFDM signal
cp_len = conf.os_factor*conf.N_subcarriers*conf.cp;
ofdm_symbol_len = conf.os_factor*conf.N_subcarriers;
training_start = start_idx+cp_len;
training_end = training_start+ofdm_symbol_len-1;
training_signal = rxsignal_bb(training_start:training_end);


%% Channel equalization
training_osfft = osfft(training_signal, conf.os_factor);

tx_training_bits = lfsr_framesync(conf.N_subcarriers); % 256-bit training
tx_training_symbols = -2 * (tx_training_bits) + 1;  % BPSK mapping

if strcmp(conf.synchronization, 'naive')
    % Call naive_phase_correction function
    [data_osffts, corr_data_osffts] = naive_phase_correction(training_osfft, tx_training_symbols, rxsignal_bb, conf, training_end, cp_len, ofdm_symbol_len);
elseif strcmp(conf.synchronization, 'channel_equalization')
    % USE channel equalization
    % Isolate data OFDM signals
    num_packets = conf.nbits / (2 * conf.N_subcarriers);
    data_osffts = [];
    
    for i = 1:num_packets
        data_start = training_end + i * cp_len + (i - 1) * ofdm_symbol_len + 1;
        data_end = data_start + ofdm_symbol_len - 1;
        data_signal = rxsignal_bb(data_start:data_end);
        packet_osfft = osfft(data_signal, conf.os_factor);

        % Only take subcarriers (ignore cyclic prefix)
        packet_osfft = packet_osfft(1:conf.N_subcarriers);
      

        % Append raw symbols (no normalization here since channel equalization handles magnitude)
        data_osffts = [data_osffts; packet_osfft]; 
    end
    
    % Call channel_equalization
    [corr_data_osffts, H_estimated] = channel_equalization(training_osfft, tx_training_symbols, data_osffts, conf);

    % Normalize corrected symbols to unit circle
    corr_data_osffts = corr_data_osffts ./ abs(corr_data_osffts);
end


%% PHASE TRACKING

if conf.plot
    plot_constellations(corr_data_osffts, 'Corrected recovered data symbols by channel equalization');
end

corr_data_osffts = phase_tracking(corr_data_osffts, training_osfft, tx_training_symbols, conf);
if conf.plot 
    plot_constellations(corr_data_osffts, 'Corrected recovered data symbols by phase tracking');
end

recovered_bits = demapper(corr_data_osffts);
if conf.plot
    plot_constellations(data_osffts, 'Recovered data symbols');
    drawnow;
end
%% Demapping
% decode bits
rxbits = recovered_bits;


