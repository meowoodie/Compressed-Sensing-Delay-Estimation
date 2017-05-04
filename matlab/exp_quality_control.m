close all;
clear all;

addpath('/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/matlab/lib');

%% Preliminary

% Parameters
Fs        = 50;         % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 1;
high_freq = 3;
acc       = 100;        % The accuracy of the downsampling
times     = 200;        % The times of computation for one downsampling rate

% Preparation for utah data
root_path      = '/Users/woodie/Desktop/stacked_utah_dataset/';
center_station = '001';
other_stations = {'020' '030' '040' '025' '052' '408'};

%% EXP: Test good/bad stations of Utah Dataset

center_x = read_one_signal([root_path center_station '/all.stacked_5_mins.txt']);
n        = length(center_x);

for i=1:length(other_stations)
    fprintf('EXP: %s vs %s\n', center_station, other_stations{i});
    other_x = read_one_signal([root_path other_stations{i} '/all.stacked_5_mins.txt']);
    
    % Method 1: FFT-convolution
    conv_f = fftconv(center_x, other_x, Fs, low_freq, high_freq);
    [m_value, m_index] = max(real(conv_f));
    tau_xcorr = (m_index - n) * Ts;
    fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);
    
    % Method 2: Compressed Sensing
    tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
    tau_cs   = estimate_lag(center_x, other_x, Fs, low_freq, high_freq, 1, tau0_ind);
    fprintf('Compressed Sensing Tau: %s\n', tau_cs);
    
    % Error vs Downsampling rate
    ds_rates = linspace(0, 1, acc);  ds_rates(1) = []; % Remove value 0
    tau_list = zeros(1, acc - 1);
    for k = 1:acc-1
        taus = zeros(1, times);
        for j = 1:times
            taus(j) = estimate_lag(center_x, other_x, Fs, low_freq, high_freq, ds_rates(k), tau0_ind);
        end
        tau_list(k) = mean(taus);
        % fprintf('Downsampling rate:%f\n', ds_rates(k));
        % fprintf('Tau:\t%0.8f\n', tau_list(k));
    end
    real_tau = tau_cs * ones(1, length(tau_list)); % xcorr tau over downsampling rate
    error    = abs(real_tau - tau_list);           % error over downsampling rate
    
    x_axis   = (1:length(tau_list)) / (acc/100);   % downsampling rate 0-100%
    f = figure('visible', 'off');
    plot(x_axis, error); xlabel('downsampling rate(%)'); ylabel('Error (s)');
    myboldify(f);
    res_path = [ ... 
        '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/result/utah_result/' ...
        sprintf('EXP.%s_vs_%s.jpg', center_station, other_stations{i})];
    saveas(f, res_path, 'jpg');
end
