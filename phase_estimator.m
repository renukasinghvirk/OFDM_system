function [payload_data] = phase_estimator(payload_data, initial_estimate, data_length, conf)
%PHASE_ESTIMATOR Summary of this function goes here
%   Detailed explanation goes here

theta_hat = zeros(data_length+1, 1);   % Estimate of the carrier phase
theta_hat(1) = initial_estimate; % initial phase estimate


    for k =1:data_length
        % Phase estimation    
        % Apply viterbi-viterbi algorithm
        deltaTheta = 1/4*angle(-payload_data(k)^4) + pi/2*(-1:4);
        
        % Unroll phase   
        [~, ind] = min(abs(deltaTheta - theta_hat(k)));
        theta = deltaTheta(ind);

        % Lowpass filter phase
        theta_hat(k+1) = mod(0.01*theta + 0.99*theta_hat(k), 2*pi);
        
        % Phase correction
        payload_data(k) = payload_data(k) * exp(-1j * theta_hat(k+1));
     
    end

    % Phase correction
    %payload_data= payload_data .* exp(-1j * theta_hat(end));

end