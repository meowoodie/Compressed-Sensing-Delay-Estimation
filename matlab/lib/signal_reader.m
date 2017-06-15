function x = signal_reader(path)
% Read signal from specific local file path
% And normalize the raw signal.
    formatSpec = '%f';
    f = fopen(path, 'r');
    x = fscanf(f, formatSpec);
    x = reshape(x, 2, length(x)/2);
    x = normc(x);
    fclose(f);
    
    figure;
    time_axis = linspace(0, floor(length(x)/50), length(x));
    freq_axis = linspace(-25, 25, length(x));
    subplot(2,1,1); plot(time_axis, x, 'b'); xlabel('Time (s)'); title('time domain');
    subplot(2,1,2); plot(freq_axis, fftshift(abs(fft(x))), 'b'); xlabel('Freq (hz)'); title('freq domain');
end

%     f = figure('visible', 'off');
%     subplot(4,1,1); plot(time_axis, x1, 'b'); xlabel('Time (s)'); title('x1 time domain');
%     subplot(4,1,2); plot(time_axis, x2, 'r'); xlabel('Time (s)'); title('x2 time domain');
%     subplot(4,1,3); plot(freq_axis, fftshift(abs(fft(x1))), 'b'); xlabel('Freq (hz)'); title('x1 freq domain');
%     subplot(4,1,4); plot(freq_axis, fftshift(abs(fft(x2))), 'r'); xlabel('Freq (hz)'); title('x2 freq domain');
%     myboldify(f);
%     
%     res_path = [ ... 
%         '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/real_result/' ...
%         res_name ... 
%         '.jpg'];
%     saveas(f,res_path,'jpg');
