classdef paint
    methods(Static)
        %% Plot signal
        % Plot the original signal in time domain and its spectrum in the
        % frequency domain
        function f = signal( x, Fs )
            f = figure; % ('visible', 'off');
            time_axis = linspace(0, floor(length(x)/Fs), length(x));
            freq_axis = linspace(-1*(Fs/2), Fs/2, length(x));
            subplot(2,1,1); plot(time_axis, x, 'b'); 
            xlabel('Time (s)'); 
            title('signal in time domain');
            subplot(2,1,2); plot(freq_axis, fftshift(abs(fft(x))), 'b'); 
            xlabel('Freq (hz)'); 
            title('signal in freq domain');
        end
        
        %% Plot cross correlation curve
        % Plot the cross correlation curve in time domain, the x-axis of 
        % the center of this curve must be zero.
        function f = xcorr( Y, Fs )
            f = figure; % ('visible', 'off');
            time_axis = linspace( ...
                -1*floor(length(Y)/Fs)/2, ...
                floor(length(Y)/Fs)/2, ...
                length(Y));
            plot(time_axis, real(Y), 'b'); 
            xlabel('Time (s)'); 
            title('cross-correlation in time domain');
        end
        
        %% Plot cost function of the compressed-sensing method
        % Plot the cost function of the compressed-sensing method, the
        % input parameters includes the cost function curves and its
        % x-axis. 
        function f = compressed_sensing( cost_val, tau_val )
            f = figure; % ('visible', 'off');
            plot(tau_val, real(cost_val), 'b'); 
            xlabel('Time (s)'); 
            title('cost function of the compressed-sensing method');
        end
    end
end

