==close all;
clear all;

addpath('/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/matlab/lib');

% Parameters
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 0;   %14.8;
high_freq = 200; %15.8;

% Prepare simulated data
res_name = 'test';
n = 10000;
time_ind = 1:n;
period   = 5000;
tau_ind  = 400;
sigma    = 0.5;
[x1, x2] = signal_generator(time_ind, tau_ind, period, Fs, sigma, res_name);

%% For non-noise data
tau0_ind = tau_ind; % The initial tau for the method 2
tau_cs   = estimate_lag(x1, x2, Fs, low_freq, high_freq, 1, tau0_ind);
fprintf('Compressed Sensing Tau index: %d\n', tau_cs/Ts);
fprintf('Compressed Sensing Tau: %s\n', tau_cs);

%% EXP2: tau over sigma of the noise
max_sigma = 10;
acc       = 1000;
sigma     = linspace(0, max_sigma, acc);
tau_list  = zeros(1, acc);
for i = 1:acc
    [x1, x2]    = signal_generator(time_ind, tau_ind, period, Fs, sigma(i));
    tau_list(i) = estimate_lag(x1, x2, Fs, low_freq, high_freq, 1, tau0_ind);
    fprintf('Compressed Sensing Tau index: %d\n', tau_cs/Ts);
    fprintf('Compressed Sensing Tau: %s\n', tau_cs);
end

real_tau = tau0_ind * Ts * ones(1, length(tau_list)); % xcorr tau over downsampling rate
error    = abs(real_tau - tau_list);         % error over downsampling rate

f = figure; 
subplot(2,1,1); plot(sigma, tau_list, 'r', sigma, real_tau, 'b'); xlabel('Sigma of Noise'); ylabel('Tau (s)');
subplot(2,1,2); plot(sigma, error); xlabel('Sigma of Noise'); ylabel('Error (s)');
myboldify(f);