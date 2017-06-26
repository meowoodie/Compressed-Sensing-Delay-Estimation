close all;
clear all;

addpath('lib');

%% Preliminary

% Prepare real data
% path_1 = '/Users/woodie/Desktop/utah/001/001.EHZ.10212016.txt';
% path_2 = '/Users/woodie/Desktop/utah/020/020.EHZ.10212016.txt';
% x1 = signal_reader(path_1);
% x2 = signal_reader(path_2);
% n  = length(x1); % The length of the signal
path_1 = '/Users/woodie/Desktop/utah/001';
path_2 = '/Users/woodie/Desktop/utah/020';
x1 = stack(path_1, {...
    '001.EHZ.09162016.txt', '001.EHZ.09172016.txt', '001.EHZ.09182016.txt' ...
    '001.EHZ.09192016.txt', '001.EHZ.09202016.txt', '001.EHZ.09212016.txt' ...
    '001.EHZ.09222016.txt'});
x2 = stack(path_2, {...
    '020.EHZ.09162016.txt', '020.EHZ.09172016.txt', '020.EHZ.09182016.txt' ...
    '020.EHZ.09192016.txt', '020.EHZ.09202016.txt', '020.EHZ.09212016.txt' ...
    '020.EHZ.09222016.txt'});
n  = length(x1); % The length of the signal

% Parameters
Fs        = 50;       % Sampling rate
Ts        = 1.0 / Fs; % Time interval
low_freq  = 1;
high_freq = 3;
window_size = 5 * 60 * Fs;

% Plot raw signals
paint.signal(x1, Fs);
paint.signal(x2, Fs);

% Gaussian Filter
filter = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size, Fs);
        
%% Method 1: FFT-convolution

R_list = batch_proc(x1, x2, window_size, @(sig_a, sig_b) ...
	abs(real(fftconv(sig_a, sig_b, Fs, low_freq, high_freq))).^2);

R = mean(R_list);
[m_value, m_index] = max(real(R));
tau_xcorr = (m_index - n) * Ts;
fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);

%% Method 2: Compressed-Sensing

Y_list = batch_proc(x1, x2, window_size, @(sig_a, sig_b) ...
	compressed_sensing.sub_cost_function(sig_a, sig_b, filter));

Y = mean(Y_list);
non_zero_ind = find(filter);
[tau, tau_val, cost_val] = compressed_sensing.solution( ...
    Y, Fs, tau_xcorr / Ts, n, non_zero_ind, 10000);
fprintf('Compressed Sensing Tau: %s\n', tau);

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