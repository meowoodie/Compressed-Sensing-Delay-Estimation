function cost_val = compressed_sensing( x1, x2, filter, tau_val )
% Sub Cost Function

    % Parameters
    n = length(x1); % The length of the signal
    % Ts = 1/Fs;       % The time interval

    % Do FFT for each of the signals
    x1_fft = fft(x1, n); % same size as x1
    x2_fft = fft(x2, n); % same size as x2

    % Apply bandpass filter
    x1_filter = x1_fft .* filter;
    x2_filter = x2_fft .* filter;

    % Remove the zero value.
    non_zero_ind = find(filter);
    x1_filter = x1_filter(non_zero_ind);
    x2_filter = x2_filter(non_zero_ind);
    % Get non zeor f_k list
    freq_range = (0:n-1) / n;
    freq_range = freq_range(non_zero_ind);

    % Cost function
    Y        = (x1_filter) .* conj(x2_filter) .* (abs(x1_filter) .^2);
    cost_val = zeros(1, length(tau_val));
    for i = 1:length(tau_val)
        p = exp(-1.0 .* complex(0,1) .* 2 .* pi .* tau_val(i) .* freq_range);
        cost_val(i) = 2 * abs(real(sum(Y .* p)))^2;
    end
end