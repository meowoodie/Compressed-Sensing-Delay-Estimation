close all;
clear all;

addpath('lib');

%% Preliminary

% Prepare real data
path_1 = '/Users/woodie/Desktop/utah/001/001.EHZ.10222016.txt';
path_2 = '/Users/woodie/Desktop/utah/020/020.EHZ.10222016.txt';
x1 = signal_reader(path_1);
x2 = signal_reader(path_2);
n  = length(x1); % The length of the signal

% Parameters
Fs        = 50;       % Sampling rate
Ts        = 1.0 / Fs; % Time interval
low_freq  = 1;
high_freq = 3;
window_size = 5 * 60 * Fs;

%% Method 1: FFT-convolution

xcorr_list = batch_proc(x1, x2, window_size, @(sig_a, sig_b) ...
    [...
        fftconv(sig_a, sig_b, Fs, low_freq, high_freq) ...
        estimate_lag(sig_a, sig_b, Fs, low_freq, high_freq, 1, tau0_ind) ...
    ]);

%% EXP1: Error (real tau - cs tau) over downsampling rate
% tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
% acc      = 100;          % The accuracy of the downsampling
% times    = 2;            % The times of computation for one downsampling rate
% ds_rates = linspace(0, 1, acc); ds_rates(1) = []; % Remove value 0
% tau_list = zeros(1, acc - 1);
% for i = 1:acc-1
%     taus = zeros(1, times);
%     for j = 1:times
%         taus(j) = estimate_lag(x1, x2, Fs, low_freq, high_freq, ds_rates(i), tau0_ind);
%     end
%     tau_list(i) = mean(taus);
%     fprintf('Downsampling rate:%f\n', ds_rates(i));
%     fprintf('Tau:\t%0.8f\n', tau_list(i));
% end
% 
% x_axis   = (1:length(tau_list)) / (acc/100); % downsampling rate 0-100%
% real_tau = tau_cs * ones(1, length(tau_list)); % xcorr tau over downsampling rate
% error    = abs(real_tau - tau_list);         % error over downsampling rate
% 
% f = figure;
% subplot(2,1,1); plot(x_axis, tau_list, 'r', x_axis, real_tau, 'b'); xlabel('downsampling rate(%)'); ylabel('Tau (s)');
% subplot(2,1,2); plot(x_axis, error); xlabel('downsampling rate(%)'); ylabel('Error (s)');
% myboldify(f);