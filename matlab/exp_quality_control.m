close all;
clear all;

addpath('/Users/woodie/Desktop/Compressed-Sensing-Delay-Estimation/matlab/lib');

%% Preliminary

% Parameters
Fs        = 500;        % Sampling rate
Ts        = 1.0 / Fs;   % Time interval
low_freq  = 1; %14.8;
high_freq = 3; %15.8;

% Prepare real data
res_name = 'frq_1hz-3hz';
path_1   = '/Users/woodie/Desktop/utah/001/';
path_2   = '/Users/woodie/Desktop/utah/020/';
x1_data  = '001.EHZ.09162016.txt';% '5R572-0000/20140325.avg.txt';
x2_data  = '020.EHZ.09162016.txt';% '6B359-0000/20140325.avg.txt';
[x1, x2] = signal_reader(path_1, path_2, x1_data, x2_data, res_name);
n        = length(x1); % The length of the signal