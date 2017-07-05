% A standard demo for reproducing the same results

close all;
clear all;

addpath('lib');
addpath('utilities');
addpath('MatSAC');

%% Preliminary

% Parameters
Fs        = 50;       % Sampling rate
Ts        = 1.0 / Fs; % Time interval
low_freq  = 1;
high_freq = 3;

% Read data from the sample of sac files
data_dir = '/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/data';
[x1_time, x1, x1_SAChdr] = fget_sac([data_dir '/2016100110200.001-0000.EHZ.sac']);
[x2_time, x2, x2_SAChdr] = fget_sac([data_dir '/2016100110200.020-0000.EHZ.sac']);
window_size = length(x1);

% Gaussian Filter
% - For fftconv
filter_Y = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size*2, Fs);
% - For compressed-sensing
filter_R = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size, Fs);

%% Preprocessing with the standard method of Utah

signal_a = transpose(x1);
signal_b = transpose(x2);
% Remove the mean value on top of the segment
signal_a = signal_a - mean(signal_a);
signal_b = signal_b - mean(signal_b);
% Whitening
if max(abs(signal_a)) ~= 0
    signal_a = bsxfun(@times, signal_a, 1./max(abs(signal_a)));
end
if max(abs(signal_b)) ~= 0
    signal_b = bsxfun(@times, signal_b, 1./max(abs(signal_b)));
end
% Taper
w_sigma = window_size/2;
w_mean  = window_size/2;
gaussian_window = normpdf((1:window_size), w_mean, w_sigma);
signal_a = signal_a .* gaussian_window;
signal_b = signal_b .* gaussian_window;

%% Cross-correlation

% Raw fftconv curve
Y     = fftconv(signal_a, signal_b); % Do fftconv
sub_Y = Y(window_size-10*Fs:window_size+10*Fs);
paint.xcorr(real(sub_Y), Fs);

% Filtered fftconv curve
frq_Y = fft(Y, length(Y));  % frequency domain of Y
frq_Y = frq_Y .* filter_Y;  % bandpass Y by a gaussian filter
Y_filter     = ifft(frq_Y); % time domain of Y after filtering
sub_Y_filter = Y_filter(window_size-10*Fs:window_size+10*Fs);
paint.xcorr(real(sub_Y_filter), Fs);