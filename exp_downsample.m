close all;
clear all;

%% Preliminary

% Prepare real data
path     = '/Users/woodie/Desktop/Georgia-Tech-ISyE-Intern/time_delay_estimation/data/average_24hr_6v538-73392/';
x1_data  = '73392_0000.txt';
x2_data  = '73395_0000.txt';
[x1, x2] = signal_reader(path, x1_data, x2_data);

% Prepare simulated data
% n = 10000;
% time_ind = 1:n;
% period   = 5000;
% tau_ind  = 150;
% sigma    = 0.01;
% [x1, x2] = signal_generator(time_ind, tau_ind, period, Fs, sigma);

% Parameters
n         = length(x1); % The length of the signal
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 14.8;
high_freq = 15.8;

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

% %% EXP1: Error (real tau - cs tau) over downsampling rate
% tau0_ind = tau_xcorr/Ts; % The initial tau for the method 2
% acc      = 10;           % The accuracy of the downsampling
% times    = 1000;         % The times of computation for one downsampling rate
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