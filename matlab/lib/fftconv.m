function R = fftconv(x1, x2, Fs, low_freq, high_freq)
    %% Padding zeros
    x1 = [x1 zeros(1, length(x1))];
    x2 = [x2 zeros(1, length(x2))];
    n  = length(x1); % The length of the signal

    %% Do FFT for each of the signals
    x1_fft = fft(x1, n); % same size as x1
    x2_fft = fft(x2, n); % same size as x2

    %% apply bandpass filter
    filter = filters.gaussian_filter(low_freq, high_freq, 1, n, Fs);

    x1_filter = x1_fft .* filter;
    x2_filter = x2_fft .* filter;

    %% Cross-correlation by FFT -> convolution -> IFFT
    cross = conj(x1_filter) .* x2_filter;
    R = fftshift(ifft(cross));

end