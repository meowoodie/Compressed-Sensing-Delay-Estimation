% Experiment for calculating the avearge error by applying different 
% downsampling rates in the compressed-sensing method

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
search_width = 10;    % in seconds
times     = 100;      % The number of the filters with all possible downsampling rates

% Gaussian Filter
% - For fftconv
filter_Y = filters.gaussian_filter( ...
    low_freq, high_freq, 1, window_size*2, Fs);
% - For Compressed-Sensing
filter_Rs = [];
for i=1:times
    filter_Rs = [ filter_Rs; ...
        filters.gaussian_filter(low_freq, high_freq, i/times, window_size, Fs) ];
end

%% Preparation
root_path = '/Users/woodie/Desktop/utah';
dir_info  = dir(root_path);
station_list = cell(1,length(dir_info)-3);

% Get the list of directory names
j = 1;
for i = 1:length(dir_info)
    if ~strcmp(dir_info(i).name, '.') && ...
       ~strcmp(dir_info(i).name, '..') && ...
       ~strcmp(dir_info(i).name, '.DS_Store')
        station_list{j} = dir_info(i).name;
        j = j + 1;
    end
end

% Get all the possible pairs (combinations) of the indexs for each of the 
% directory
% WARN: combvec might not be compatible with Octave. Please use 
%       combine_pair in the utilites.

% Compatible with Octave.
ind_pair_list = combine_pair(1:length(station_list));

%% Loop for each of the windows

% First loop for each of the stations
for i=1:size(ind_pair_list,2)
    station_A = station_list{ind_pair_list(1, i)};
    station_B = station_list{ind_pair_list(2, i)};
    date_list = { ...
        '10162016', '10172016', '10182016', '10192016', ...
        '10202016', '10212016', '10222016'};
    
    % Second loop for each of the dates in a specific station
    for i=1:length(date_list)
        %% Preprocessing
        
        fprintf('Reading Data on %s ...\n', date_list{i});
        % Read signal x1 and x2
        x1 = signal_reader([root_path '/' station_A '/' ...
            station_A '.EHZ.' date_list{i} '.txt']);
        x2 = signal_reader([root_path '/' station_B '/' ...
            station_B '.EHZ.' date_list{i} '.txt']);
        
        %% Estimate time delay (tau) by cross correlation
        
        % Preprocess signals and calculate their fftconv function in batch 
        % for each of their windows
        Ys = batch_windows(x1, x2, window_size, @fftconv);
        Y  = mean(Ys);
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
        % paint.xcorr(sub_Y_filter, Fs); % Plot the cross-correlation curve

        %% Estimate time delay (tau) by compressed-sensing method
        
        % Preprocess signals and calculate their compressed-sensing cost
        % function with different downsampling rate in batch for each of 
        % their windows.
        Rss = batch_windows(x1, x2, window_size, @(sig_a, sig_b) ...
            batch_filters(sig_a, sig_b, filter_Rs));
        % Reshape Rss from (num_segments, num_filters, size_cost_function)
        % to (num_filters, num_segments, size_cost_function)
        Rss = reshape(Rss, ...
            times, floor(length(x1)/window_size), window_size);
        non_zero_ind = find(filter_R);
        [tau, tau_val, cost_val] = compressed_sensing.solution( ...
            R, Fs, 0, window_size, non_zero_ind, search_width);
        fprintf('Compressed Sensing Tau: %s\n', tau);
        % paint.compressed_sensing(cost_val, tau_val); % Plot the cross-correlation curve
        return 
    end
end

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