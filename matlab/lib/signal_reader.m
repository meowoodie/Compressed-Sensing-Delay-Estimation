function [x1, x2] = signal_reader(path_1, path_2, x1_data, x2_data, res_name)
%     path = '/Users/woodie/Desktop/Georgia-Tech-ISyE-Intern/time_delay_estimation/data/average_24hr_6v538-73392/';
    formatSpec = '%f';
    
%     f1 = fopen([path '73392_0000.txt'],'r');
    f1 = fopen([path_1 x1_data],'r');
    x1 = fscanf(f1,formatSpec);
    x1 = normc(x1);
    fclose(f1);

%     f2 = fopen([path '73395_0000.txt'],'r');
    f2 = fopen([path_2 x2_data],'r');
    x2 = fscanf(f2,formatSpec);
    x2 = normc(x2);
    fclose(f2);
    
    time_axis = linspace(0, 3600, length(x1));
    freq_axis = linspace(-250, 250, length(x1));
    
    f = figure('visible', 'off');
    subplot(4,1,1); plot(time_axis, x1, 'b'); xlabel('Time (s)'); title('x1 time domain');
    subplot(4,1,2); plot(time_axis, x2, 'r'); xlabel('Time (s)'); title('x2 time domain');
    subplot(4,1,3); plot(freq_axis, fftshift(abs(fft(x1))), 'b'); xlabel('Freq (hz)'); title('x1 freq domain');
    subplot(4,1,4); plot(freq_axis, fftshift(abs(fft(x2))), 'r'); xlabel('Freq (hz)'); title('x2 freq domain');
    myboldify(f);
    
    res_path = [ ... 
        '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/real_result/' ...
        res_name ... 
        '.jpg'];
    saveas(f,res_path,'jpg');
end

