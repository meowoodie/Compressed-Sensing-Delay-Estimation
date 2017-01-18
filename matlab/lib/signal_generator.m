function [x1, x2] = signal_generator(time_ind, tau, period, Fs, sigma, res_name)

    x1 = sin(2*pi*time_ind/period) + sigma.^2*randn(length(time_ind),1)';
    x2 = sin(2*pi*(time_ind - tau)/period) + sigma.^2*randn(length(time_ind),1)';
    
    time_axis = linspace(0, length(time_ind) / Fs, length(time_ind));
    freq_axis = linspace(-Fs/2, Fs/2, length(time_ind));
    
    f = figure('visible', 'off');
    subplot(4,1,1); plot(time_axis, x1, 'b'); xlabel('Time (s)'); title('x1 time domain');
    subplot(4,1,2); plot(time_axis, x2, 'r'); xlabel('Time (s)'); title('x2 time domain');
    subplot(4,1,3); plot(freq_axis, fftshift(abs(fft(x1))), 'b'); xlabel('Freq (hz)'); title('x1 freq domain');
    subplot(4,1,4); plot(freq_axis, fftshift(abs(fft(x2))), 'r'); xlabel('Freq (hz)'); title('x2 freq domain');
    myboldify(f);
    
    res_path = [ ... 
        '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/exp_result/' ...
        res_name ... 
        '.jpg'];
    saveas(f, res_path, 'jpg');

    x1 = x1';
    x2 = x2';
end
