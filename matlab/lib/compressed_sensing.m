classdef compressed_sensing
    methods (Static)
        function Y = sub_cost_function( ...
            x1, x2)
        % Sub Cost Function
        
            % Parameters
            n = length(x1); % The length of the signal
            % Ts = 1/Fs;       % The time interval

            % Do FFT for each of the signals
            x1_fft = fft(x1, n); % same size as x1
            x2_fft = fft(x2, n); % same size as x2

            % Apply bandpass filter
            % x1_filter = x1_fft .* filter;
            % x2_filter = x2_fft .* filter;

            % Remove the zero value.
            % non_zero_ind = find(filter);
            % x1_filter = x1_fft(non_zero_ind);
            % x2_filter = x2_fft(non_zero_ind);
            % freq_range = freq_range(non_zero_ind);
            
            % Cost function
            Y = (x1_fft) .* conj(x2_fft) .* (abs(x1_fft) .^2);
        end
        
        function [ tau, tau_val, cost_val ] = solution(Y, Fs, init_ind, ...
                n, search_width)
        % Solution    
      
            Ts = 1 / Fs;
            freq_range = (0:n-1) / n;
            % freq_range = freq_range(non_zero_ind);
            tau_val    = (...
                init_ind / Ts - search_width : ...
                init_ind / Ts + search_width) * Ts;
            % tau_val    = linspace( ...
            %     init_tau - search_width, ... % Start of the range tau
            %     init_tau + search_width, ... % End of the range tau
            %     search_length);              % Accuracy of the search range
            cost_val   = zeros(1, length(tau_val));
            for i = 1:length(tau_val)
                p = exp(-1.0 .* complex(0,1) .* 2 .* pi .* tau_val(i) .* freq_range);
                cost_val(i) = 2 * abs(real(sum(Y .* p)))^2;
            end
            
            % Get estimated tau value
            [min_cost, index] = min(cost_val);
            tau = tau_val(index) * Ts;
        end
    end
end