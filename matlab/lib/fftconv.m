function conv_f = fftconv(x1, x2, Fs, low_freq, high_freq)
    % Padding zeros
    x1 = [x1' zeros(1, length(x1))];
    x2 = [x2' zeros(1, length(x2))];

    n  = length(x1); % The length of the signal
    % Fs = 500;        % Sampling rate
    % Ts = 1.0 / Fs;   % Time interval
    % T  = n * Ts;     % The duration of the signal

    % Do FFT for each of the signals
    x1_fft = fft(x1, n); % same size as x1
    x2_fft = fft(x2, n); % same size as x2

    % fig_1 = figure;
    % subplot(2,1,1); plot(abs(x1_fft));
    % subplot(2,1,2); plot(abs(x2_fft));

    % apply bandpass filter
    ideal_BP = filters.ideal_BP_filter(low_freq, high_freq, n, Fs);

    x1_filter = x1_fft .* ideal_BP;
    x2_filter = x2_fft .* ideal_BP;

%     f1 = figure;
%     subplot(2,1,1); plot(fftshift(abs(x1_filter))); title('filtered x1 freq domain');
%     subplot(2,1,2); plot(fftshift(abs(x2_filter))); title('filtered x2 freq domain');
%     myboldify(f1);

    % Cross-correlation by FFT -> convolution -> IFFT
    cross = conj(x1_filter) .* x2_filter;
    conv_f = fftshift(ifft(cross));

%     f2 = figure; 
%     plot(real(conv_f)); 
%     title('fftconv'); 
%     ylabel('Amplitude');
%     myboldify(f2);
end