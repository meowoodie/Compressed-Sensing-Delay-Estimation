function [x1, x2] = signal_generator(time_ind, tau, period, sigma)
%     time_ind = 1:10000;
%     period   = 3000;
%     tau      = 1000;

    x1 = sin(2*pi*time_ind/period) + sigma.^2*randn(length(time_ind),1)';
    x2 = sin(2*pi*(time_ind - tau)/period) + sigma.^2*randn(length(time_ind),1)';
    
    time_axis = linspace(0, length(time_ind) * period, length(x1));
    freq_axis = linspace(-1/period, 1/period, length(x1));
    
    f = figure;
    subplot(4,1,1); plot(time_axis, x1, 'b'); xlabel('Time (s)'); title('x1 time domain');
    subplot(4,1,2); plot(time_axis, x2, 'r'); xlabel('Time (s)'); title('x2 time domain');
    subplot(4,1,3); plot(freq_axis, fftshift(abs(fft(x1))), 'b'); xlabel('Freq (hz)'); title('x1 freq domain');
    subplot(4,1,4); plot(freq_axis, fftshift(abs(fft(x2))), 'r'); xlabel('Freq (hz)'); title('x2 freq domain');
    myboldify(f);
%     conv_time = conv(x1,x2);
    x1 = x1';
    x2 = x2';
end
