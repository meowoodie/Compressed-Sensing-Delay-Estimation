close all;
clear all;

addpath('/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/matlab/lib');

%% Preliminary

% Parameters
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 14.8;
high_freq = 15.8;

% Prepare real data
root_path     = '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation';
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
% Get all the possible pairs (combinations) of the indexs for each of the directory
ind_pair_list = combvec( ...
    1:length(dir_info_list)-2, ...
    1:length(dir_info_list)-2 ...
);
% Read signals from the local files according to the pairs
for i = 1:size(ind_pair_list, 2)
    % Ignore the pairs which have the same values 
    if ind_pair_list(1, i) ~= ind_pair_list(2, i)
        dir_a = dir_name_list{ind_pair_list(1, i)};
        dir_b = dir_name_list{ind_pair_list(2, i)};
        fprintf('Processing %s & %s ...\n', dir_a, dir_b);

        % Read the signals from the files
        path_1 = [root_path '/avg_data/' dir_a '/'];
        path_2 = [root_path '/avg_data/' dir_b '/'];
        [x1, x2] = signal_reader( ...
            path_1, path_2, file_name, file_name, [dir_a '_' dir_b] ...
        );
        
        %% Method 1: FFT-convolution
        conv_f = fftconv(x1, x2, Fs, low_freq, high_freq);
        [m_value, m_index] = max(real(conv_f));
        tau_xcorr = (m_index - n) * Ts;
        fprintf('FFT-Convolution Tau index: %d\n', (m_index - n));
        fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);

        %% Method 2: Compressed Sensing
        tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
        tau_cs   = estimate_lag(x1, x2, Fs, low_freq, high_freq, 0.4, tau0_ind);
        fprintf('Compressed Sensing Tau index: %d\n', tau_cs/Ts);
        fprintf('Compressed Sensing Tau: %s\n', tau_cs);
        
        
        
    end
end


