close all;
clear all;

addpath('/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/matlab/lib');

%% Preliminary

% Parameters
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 1;
high_freq = 3;

% Preparation for utah data
root_path      = '/Users/woodie/Desktop/utah/';
center_station = '010';
other_stations = {'020' '030' '040' '025' '052' '408'};

%% EXP: Test good/bad stations of Utah Dataset

center_x = read_one_signal([root_path center_station '/stacked_5_mins.txt']);
n        = length(center_x);

for i=1:length(other_stations)
    other_x = read_one_signal([root_path other_stations{i} '/stacked_5_mins.txt']);
    
    % Method 1: FFT-convolution
    conv_f = fftconv(center_x, other_x, Fs, low_freq, high_freq);
    [m_value, m_index] = max(real(conv_f));
    tau_xcorr = (m_index - n) * Ts;
    fprintf('FFT-Convolution Tau index: %d\n', (m_index - n));
    fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);
    
    % Method 2: Compressed Sensing
    tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
    tau_cs   = estimate_lag(center_x, other_x, Fs, low_freq, high_freq, 1, tau0_ind);
    fprintf('Compressed Sensing Tau index: %d\n', tau_cs/Ts);
    fprintf('Compressed Sensing Tau: %s\n', tau_cs);
end
