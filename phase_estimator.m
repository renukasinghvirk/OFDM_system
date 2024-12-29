function [payload_data] = phase_estimator(payload_data, initial_estimate, data_length, conf)
%   PHASE_ESTIMATOR Performs carrier phase estimation and correction for a signal.
%   This function estimates and corrects the carrier phase of the input 
%   signal using the Viterbi-Viterbi algorithm. It applies a lowpass filter 
%   to the phase estimates for smooth correction.
%
%   INPUTS:
%   - payload_data: A complex vector representing the received signal payload.
%   - initial_estimate: The initial phase estimate (in radians).
%   - data_length: Length of the payload data to process.
%   - conf: Configuration struct (not used directly, reserved for flexibility).
%
%   OUTPUT:
%   - payload_data: The phase-corrected payload signal.
%
%   The function performs the following steps:
%   1. Estimates the carrier phase using the Viterbi-Viterbi algorithm.
%   2. Unrolls the phase to handle ambiguities and wraps it into the correct range.
%   3. Applies a lowpass filter to smooth the phase estimates.
%   4. Corrects the phase of the input signal based on the estimated phase.

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
 
end