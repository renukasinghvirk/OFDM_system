% % % % %
% copy of the audiotrans_ofdm.m file for CP overhead analysis on BER and
% spectral efficiency


%% Configuration Values
conf.audiosystem = 'matlab'; % Values: 'matlab','native','bypass'

conf.f_s     = 48000;   % sampling rate  
conf.f_sym   = 100;     % symbol rate
conf.nframes = 1;       % number of frames to transmit
conf.modulation_order = 2; % BPSK:1, QPSK:2
conf.f_c     = 4000;
conf.npreamble  = 100; %(= number of symbols because BPSK)
conf.bitsps     = 16;   % bits per audio sample
conf.offset     = 0;
conf.synchronization = 'channel_equalization'; % Values: 'naive', 'channel_equalization'
conf.N_subcarriers = 256;
conf.nbits   = (conf.N_subcarriers*conf.modulation_order)*4;    % number of bits => 1000 symbols because QPSK
conf.spacing = 5;
conf.os_factor = conf.f_s / (conf.spacing*conf.N_subcarriers);
conf.plot = false;

% Init Section
% all calculations that you only have to do once
conf.os_factor_preamble  = conf.f_s/conf.f_sym;
if mod(conf.os_factor,1) ~= 0
   disp('WARNING: Sampling rate must be a multiple of the symbol rate'); 
end
conf.nsyms      = ceil(conf.nbits/conf.modulation_order);

% Initialize result structure with zero
res.biterrors   = zeros(conf.nframes,1);
res.rxnbits     = zeros(conf.nframes,1);

% Initialize CP overheads
num_points = 5;
cp_values = logspace(log10(0.1), log10(0.5), num_points); 

% Initialize BER vector with zeros, same size as cp_values
BER = zeros(1, length(cp_values));

for i=1:length(cp_values)
    conf.cp = cp_values(i);
    disp('CP overhead:');
    disp(conf.cp);
    % Results
    for k=1:conf.nframes    
        % Generate random data
        txbits = randi([0 1],conf.nbits,1);
       
       
        
        % TODO: Implement tx() Transmit Function
        [txsignal conf] = tx(txbits,conf,k);
        
        % % % % % % % % % % % %
        % Begin
        % Audio Transmission
        %
        
        % normalize values
        peakvalue       = max(abs(txsignal));
        normtxsignal    = txsignal / (peakvalue + 0.3);
        
        % create vector for transmission
        rawtxsignal = [ zeros(conf.f_s,1) ; normtxsignal ;  zeros(conf.f_s,1) ]; % add padding before and after the signal
        rawtxsignal = [  rawtxsignal  zeros(size(rawtxsignal)) ]; % add second channel: no signal
        txdur       = length(rawtxsignal)/conf.f_s; % calculate length of transmitted signal
        
    %     wavwrite(rawtxsignal,conf.f_s,16,'out.wav')   
        audiowrite('out.wav',rawtxsignal,conf.f_s)  
        
        % Platform native audio mode 
        if strcmp(conf.audiosystem,'native')
            
            % Windows WAV mode 
            if ispc()
                disp('Windows WAV');
                wavplay(rawtxsignal,conf.f_s,'async');
                disp('Recording in Progress');
                rawrxsignal = wavrecord((txdur+1)*conf.f_s,conf.f_s);
                disp('Recording complete')
                rxsignal = rawrxsignal(1:end,1);
    
            % ALSA WAV mode 
            elseif isunix()
                disp('Linux ALSA');
                cmd = sprintf('arecord -c 2 -r %d -f s16_le  -d %d in.wav &',conf.f_s,ceil(txdur)+1);
                system(cmd); 
                disp('Recording in Progress');
                system('aplay  out.wav')
                pause(2);
                disp('Recording complete')
                rawrxsignal = audioread('in.wav');
                rxsignal    = rawrxsignal(1:end,1);
            end
            
    
        % MATLAB audio mode
        elseif strcmp(conf.audiosystem,'matlab')
            disp('MATLAB generic');
            playobj = audioplayer(rawtxsignal,conf.f_s,conf.bitsps);
            recobj  = audiorecorder(conf.f_s,conf.bitsps,1);
            record(recobj);
            disp('Recording in Progress');
            playblocking(playobj)
            pause(0.5);
            stop(recobj);
            disp('Recording complete')
            rawrxsignal  = getaudiodata(recobj,'int16');
            rxsignal     = double(rawrxsignal(1:end))/double(intmax('int16')) ;
            
        elseif strcmp(conf.audiosystem,'bypass')
            rawrxsignal = rawtxsignal(:,1);
            rxsignal    = rawrxsignal;
        end
     
        % End
        % Audio Transmission   
        % % % % % % % % % % % %
        
        % TODO: Implement rx() Receive Function
        [rxbits conf]       = rx(rxsignal,conf);
    
        
        res.rxnbits(k)      = length(rxbits);  
        res.biterrors(k)    = sum(rxbits ~= txbits);
        
    end
    
    per = sum(res.biterrors > 0)/conf.nframes
    ber = sum(res.biterrors)/sum(res.rxnbits)
    BER(i) = ber;
    
end

   % Plot BER vs CP length
    figure('Units', 'pixels', 'Position', [100, 100, 500, 500]);
    semilogx(cp_values * 100, BER * 100, '--o', 'LineWidth', 2, 'Color', 'r'); % Use semilogx for log scale on x-axis
    
    % Customize axis labels
    xlabel('CP Overhead (fraction of symbol duration)', 'FontSize', 20);
    ylabel('BER (%)', 'FontSize', 20);
    title('BER vs CP overhead', 'FontSize', 25);
    
    % Customize ticks on the x-axis to show decimal values
    xticks(cp_values * 100); % Set specific tick positions
    xticklabels(arrayfun(@(x) sprintf('%.2f', x), cp_values * 100, 'UniformOutput', false)); % Format tick labels
    
    % Adjust font size for axis ticks
    ax = gca; % Get current axes
    ax.FontSize = 20; % Set font size for axis tick labels
    grid on;
    
    % Set x-axis and y-axis limits
    xlim([min(cp_values * 100) max(cp_values * 100)]); % Adjust limits to the range of cp_values
    ylim([0 max(BER * 100 + 1)]); % BER range in percentage


% Compute spectral efficiency for each CP overhead value
spectral_efficiency = conf.modulation_order * (1 - cp_values);

% Plot Spectral Efficiency vs CP Overhead with logarithmic x-axis
figure('Units', 'pixels', 'Position', [100, 100, 700, 500]);
semilogx(cp_values, spectral_efficiency, '-o', 'LineWidth', 2, 'MarkerSize', 8, 'Color', [0, 0.4470, 0.7410]);

% Customize plot
xlabel('CP Overhead (fraction of symbol duration)', 'FontSize', 20);
ylabel('Spectral Efficiency (bits/s/Hz)', 'FontSize', 20);
title('Spectral Efficiency vs CP Overhead', 'FontSize', 25);
grid on;

% Adjust axis limits
xlim([min(cp_values), max(cp_values)]);
ylim([min(spectral_efficiency) - 0.1, conf.modulation_order]); % Ensure y-axis starts slightly below min efficiency

% Customize ticks to avoid scientific notation
xticks(cp_values); % Use the exact values from cp_values
xticklabels(arrayfun(@(x) sprintf('%.4f', x), cp_values, 'UniformOutput', false)); % Format as decimal values
ax = gca; % Get current axes
ax.FontSize = 20; % Set font size for axis tick labels
grid on;