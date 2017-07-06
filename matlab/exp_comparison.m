% Experiment for comparing traditional cross-correlation (fftconv) method
% and compressed-sensing method on the data within an indicated range of
% dates.

close all;
clear all;

addpath('lib');
addpath('utilities');

%% Preliminary

% Parameters
Fs        = 50;       % Sampling rate
Ts        = 1.0 / Fs; % Time interval
low_freq  = 1;
high_freq = 3;
window_size  = 5 * 60 * Fs;
search_width = 40;    % in seconds
init_tau     = 0;

% Gaussian Filter
% - For fftconv
filter_Y = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size*2, Fs);
% - For compressed-sensing
filter_R = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size, Fs);

%% Loop for calculating cost functions
root_path = '/Users/woodie/Desktop/utah';
station_A = '001';
station_B = '020';
date_list = { ...
    '10162016', '10172016', '10182016', '10192016', ...
    '10202016', '10212016', '10222016'};

Ys = [];
Rs = [];
for i=1:length(date_list)
    fprintf('Reading Data on %s ...\n', date_list{i});
    % Read signal x1 and x2
    x1 = signal_reader([root_path '/' station_A '/' ...
        station_A '.EHZ.' date_list{i} '.txt']);
    x2 = signal_reader([root_path '/' station_B '/' ...
        station_B '.EHZ.' date_list{i} '.txt']);
    
    % % Plot raw signals
    % paint.signal(x1, Fs);
    % paint.signal(x2, Fs);
    
    % Searching range of tau
    tau_val = linspace( ...
        init_tau - search_width, ... % Start of the range tau
        init_tau + search_width, ... % End of the range tau
        1000);                       % Accuracy of the search range
    
    fprintf('Running Core Algorithm for each of the windows ...\n');
    % Preprocessing signal x1 and x2, 
    % do the anonymous function for each of the windows
    % Res = [ [ (FFT-convolution) (Compressed-Sensing) ]; ... ]    
    Res = batch_windows(x1, x2, window_size, @(sig_a, sig_b)[ ...
        fftconv(sig_a, sig_b) ...
        compressed_sensing(sig_a, sig_b, filter_R, tau_val) ]);
    
    % the length of fftconv curve (Y) is twice of the window size.
    Ys = [ Ys; Res(:, 1:window_size*2) ]; 
    % the length of compressed sensing function (R) is uncertain, 
    % because the final function would discard those zero values after 
    % applying gaussian filter on the origin signal.
    Rs = [ Rs; Res(:, window_size*2+1:end) ];
end

% Saving middle results for further use
save('Middle_Res.mat', ...
    'Rs', 'Ys', 'Fs', 'window_size');

%% Estimate time delay (tau) by cross correlation

Y = mean(Ys);
frq_Y = fft(Y, length(Y)); % frequency domain of Y
frq_Y = frq_Y .* filter_Y; % apply gaussian filter on the frequency domain of Y
Y_filter = ifft(frq_Y);    % time domain of Y after filtering
% Only keep data within the search range
sub_Y_filter = Y_filter( ...
    window_size-search_width*Fs:window_size+search_width*Fs); 
% Find the highest peak in Y
[m_value, m_index] = max(abs(real(sub_Y_filter)).^2);
tau_xcorr = (m_index - length(sub_Y_filter)/2) * Ts;
% Print the result
fprintf('FFT-Convolution Tau: %s\n', tau_xcorr);
paint.xcorr(sub_Y_filter, Fs); % Plot the cross-correlation curve

%% Estimate time delay (tau) by compressed-sensing method

R = mean(Rs);
% Get estimated tau value
[m_cost, m_index] = max(R);
tau = tau_val(m_index);
fprintf('Compressed Sensing Tau: %s\n', tau);
% Plot the cross-correlation curve
paint.compressed_sensing(R, tau_val); 