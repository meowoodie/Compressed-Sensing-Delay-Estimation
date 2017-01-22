close all;
clear all;

addpath('lib');

%% Preliminary

% Parameters
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 14.8;
high_freq = 15.8;

% Prepare real data
root_path     = '..';
file_name     = '20140324.avg.txt';
dir_info_list = dir([root_path '/avg_data']);
dir_name_list = cell(1,length(dir_info_list)-2);

% Get the list of directory names
j = 1;
for i = 1:length(dir_info_list)
    if ~strcmp(dir_info_list(i).name, '.') && ...
       ~strcmp(dir_info_list(i).name, '..')
        dir_name_list{j} = dir_info_list(i).name;
        j = j + 1;
    end
end

% % Get all the possible pairs (combinations) of the indexs for each of the directory
% % WARN: combvec might not be compatible with Octave. Please use
% %       combine_pair in the lib.
% ind_pair_list = combvec( ...
%     1:length(dir_info_list)-2, ...
%     1:length(dir_info_list)-2 ...
% );

% Compatible with Octave.
ind_pair_list = combine_pair(1:length(dir_name_list));

%% Read data & Compute average error
 
% The final result: 
% average error for multiple pairs of stations.
sum_err = [];

% Main Loop
for i = 1:300 %size(ind_pair_list, 2)
    %% Prepare the data
    dir_a = dir_name_list{ind_pair_list(1, i)};
    dir_b = dir_name_list{ind_pair_list(2, i)};
    fprintf('Processing %s & %s ...\n', dir_a, dir_b);

    % Read the signals from the files
    path_1 = [root_path '/avg_data/' dir_a '/'];
    path_2 = [root_path '/avg_data/' dir_b '/'];
    [x1, x2] = signal_reader( ...
        path_1, path_2, file_name, file_name, [dir_a '_' dir_b] ...
    );
    n = length(x1); % The length of the signal

    %% Method 1: FFT-convolution
    conv_f = fftconv(x1, x2, Fs, low_freq, high_freq);
    [m_value, m_index] = max(real(conv_f));
    tau_xcorr = (m_index - n) * Ts;
    fprintf('FFT-Convolution Tau index: %d\n', (m_index - n));
    fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);

    %% Method 2: Compressed Sensing
    tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
    tau_cs   = estimate_lag(x1, x2, Fs, low_freq, high_freq, 1, tau0_ind);
    fprintf('Compressed Sensing Tau index: %d\n', tau_cs/Ts);
    fprintf('Compressed Sensing Tau: %s\n', tau_cs);

    %% Error (real tau - cs tau) over downsampling rate
    tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
    acc      = 100;          % The accuracy of the downsampling
    times    = 3;            % The times of computation for one downsampling rate
    ds_rates = linspace(0, 1, acc);  ds_rates(1) = []; % Remove value 0
    tau_list = zeros(1, acc - 1);
    for k = 1:acc-1
        taus = zeros(1, times);
        for j = 1:times
            taus(j) = estimate_lag(x1, x2, Fs, low_freq, high_freq, ds_rates(k), tau0_ind);
        end
        tau_list(k) = mean(taus);
%             fprintf('Downsampling rate:%f\n', ds_rates(k));
%             fprintf('Tau:\t%0.8f\n', tau_list(k));
    end

    real_tau = tau_cs * ones(1, length(tau_list)); % xcorr tau over downsampling rate
    error    = abs(real_tau - tau_list);           % error over downsampling rate

%         x_axis   = (1:length(tau_list)) / (acc/100);   % downsampling rate 0-100%
%         f = figure;
% %         subplot(2,1,1); plot(x_axis, tau_list, 'r', x_axis, real_tau, 'b'); xlabel('downsampling rate(%)'); ylabel('Tau (s)');
% %         subplot(2,1,2); 
%         plot(x_axis, error); xlabel('downsampling rate(%)'); ylabel('Error (s)');
%         myboldify(f);

    sum_err = [sum_err; error];        
end

% Compute the mean for each of the errors
avg_err = mean(sum_err);

x_axis  = (1:length(tau_list)) / (acc/100);   % downsampling rate 0-100%

f = figure;
% subplot(2,1,1); plot(x_axis, tau_list, 'r', x_axis, real_tau, 'b'); xlabel('downsampling rate(%)'); ylabel('Tau (s)');
% subplot(2,1,2); 
plot(x_axis, avg_err); xlabel('downsampling rate(%)'); ylabel('Error (s)');
myboldify(f);

save('error_over_downsampling.mat', 'sum_err', 'avg_err');

