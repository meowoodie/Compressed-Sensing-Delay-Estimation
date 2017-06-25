function x = signal_reader(path)
% Read signal from specific local file path
% And normalize the raw signal.
    formatSpec = '%f';
    f = fopen(path, 'r');
    x = fscanf(f, formatSpec);
    x = transpose(reshape(x, 2, length(x)/2));
    x = normc(x(:,2));
    fclose(f);

%     myboldify(f);
%     res_path = [ ... 
%         '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/real_result/' ...
%         res_name ... 
%         '.jpg'];
%     saveas(f,res_path,'jpg');

end
