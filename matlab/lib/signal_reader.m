function x = signal_reader(path)
% Read signal from specific local file path
% And normalize the raw signal.
    formatSpec = '%f';
    f = fopen(path, 'r');
    x = fscanf(f, formatSpec);
    x = transpose(reshape(x, 2, length(x)/2));
    x = normc(x(:,2));
    fclose(f);
    
    f = figure; % ('visible', 'off');
    time_axis = linspace(0, floor(length(x)/50), length(x));
    freq_axis = linspace(-25, 25, length(x));
    subplot(2,1,1); plot(time_axis, x, 'b'); xlabel('Time (s)'); title('time domain');
    subplot(2,1,2); plot(freq_axis, fftshift(abs(fft(x))), 'b'); xlabel('Freq (hz)'); title('freq domain');
%     myboldify(f);
%     res_path = [ ... 
%         '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/real_result/' ...
%         res_name ... 
%         '.jpg'];
%     saveas(f,res_path,'jpg');

end
