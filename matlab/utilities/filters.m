classdef filters
    methods(Static)
        function filter = ideal_filter(...
                low_freq, high_freq, ... % The range of band pass
                downsample_rate, ...     % downsampling rate
                n, Fs)
            % Index of low frequency and high frequency in the positive
            % frequency domain
            ind_low  = round(low_freq * n / Fs) + 1;
            ind_high = round(high_freq * n / Fs) + 1;
            filter = zeros(1, n);
            % Positive freq part
            filter(ind_low:ind_high - 1) = ones(1, ind_high - ind_low); 
            % Negative freq part
            filter(n - ind_high + 1:n - ind_low) = ones(1, ind_high - ind_low);
            % Downsampling
            if downsample_rate < 1
                non_sample_num = round((1 - downsample_rate) * (ind_high - ind_low));
                pos_non_sample_ind = randsample(ind_low:ind_high - 1, non_sample_num);
                neg_non_sample_ind = n - pos_non_sample_ind + 1;
                filter([pos_non_sample_ind neg_non_sample_ind]) = 0;
            end 
        end
        
        function filter = gaussian_filter(...
                low_freq, high_freq, ... % The range of band pass
                downsample_rate, ...     % downsampling rate
                n, Fs)
            % Index of low frequency and high frequency in the positive
            % frequency domain
            ind_low  = round(low_freq * n / Fs) + 1;
            ind_high = round(high_freq * n / Fs) + 1;
            filter = zeros(1, n);
            % Gaussian window
            sigma = (ind_high - ind_low)/6;
            mean  = (ind_high - ind_low)/2;
            gaussian_window = normpdf((1:(ind_high - ind_low)), mean, sigma);
            % Positive freq part
            filter(ind_low:ind_high - 1) = ones(1, ind_high - ind_low) .* gaussian_window; 
            % Negative freq part
            filter(n - ind_high + 1:n - ind_low) = ones(1, ind_high - ind_low) .* gaussian_window;
            % Downsampling
            if downsample_rate < 1
                non_sample_num = round((1 - downsample_rate) * (ind_high - ind_low));
                pos_non_sample_ind = randsample(ind_low:ind_high - 1, non_sample_num);
                neg_non_sample_ind = n - pos_non_sample_ind + 1;
                filter([pos_non_sample_ind neg_non_sample_ind]) = 0;
            end
            
        end
    end
end