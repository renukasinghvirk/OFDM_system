% % % % %
% Wireless Receivers: algorithms and architectures
% Audio Transmission Framework 
%
%
%   3 operating modes:
%   - 'matlab' : generic MATLAB audio routines (unreliable under Linux)
%   - 'native' : OS native audio system
%       - ALSA audio tools, most Linux distrubtions
%       - builtin WAV tools on Windows 
%   - 'bypass' : no audio transmission, takes txsignal as received signal


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

%% je rajoute ca
conf.datatype = 'random'; % Values: 'random', 'image'
conf.synchronization = 'channel_equalization'; % Values: 'naive', 'channel_equalization'
conf.N_subcarriers = 256;
conf.nbits   = (conf.N_subcarriers*2)*2;    % number of bits => 1000 symbols because QPSK
conf.spacing = 5;
conf.os_factor = conf.f_s / (conf.spacing*conf.N_subcarriers);


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

%% LOAD IMAGE

% Create the original 32x32 binary image of a smiley face
smiley = [
    zeros(8, 32);
    zeros(4, 8), ones(4, 4), zeros(4, 8), ones(4, 4), zeros(4, 8);
    zeros(2, 8), ones(2, 4), zeros(2, 8), ones(2, 4), zeros(2, 8);
    zeros(2, 8), ones(2, 4), zeros(2, 8), ones(2, 4), zeros(2, 8);
    zeros(4, 32);
    zeros(4, 6), ones(4, 20), zeros(4, 6);
    zeros(8, 32)
];

% Transpose the smiley to correct the orientation
smiley = smiley';

% Flatten the binary image into a single column vector
smiley_flat = smiley(:);

% Convert each 0 to '00000000' and each 1 to '11111111'
% This creates a bitstream where each pixel is represented as 8 bits
smiley_bitstream = repelem(smiley_flat, 8);

% Results


for k=1:conf.nframes    
    % Generate random data

    if strcmp(conf.datatype,'image')
        txbits = smiley_bitstream;
        
        image = image_decoder(txbits, [32,32]);
        imshow(image, 'InitialMagnification', 'fit', 'XData', [0 32], 'YData', [0 32]); % Scales the display to 64x64
        axis on; 
        title('Sent Image', 'FontSize', 25);
        set(gca, 'FontSize', 20);
        conf.nbits   = length(txbits); 
    elseif strcmp(conf.datatype, 'random')
        txbits = randi([0 1],conf.nbits,1);
    end
   
    
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
    
%     % Plot received signal for debugging
%     figure;
%     plot(rawrxsignal);
%     title('Received Signal')
    
    %
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
ber_ideal = ber;

if strcmp(conf.datatype, 'image')
    figure('Name', 'Received Image'); % Create a new figure for the image
    image = image_decoder(rxbits, [32,32]);
    imshow(image, 'InitialMagnification', 'fit', 'XData', [0 32], 'YData', [0 32]); % Scales the display to 64x64
    axis on; 
    title('Received image', FontSize=30);
end

