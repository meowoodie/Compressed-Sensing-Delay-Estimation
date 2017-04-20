classdef filters
    methods(Static) 
        function ideal_BP = ideal_BP_filter(low_freq, high_freq, n, Fs)
            ind_low  = round(low_freq * n / Fs) + 1;
            ind_high = round(high_freq * n / Fs) + 1;
            ideal_BP = zeros(1, n);
            % Positive freq part
            ideal_BP(ind_low:ind_high - 1) = ones(1, ind_high - ind_low); 
            % Negative freq part
            ideal_BP(n - ind_high + 1:n - ind_low) = ones(1, ind_high - ind_low); 
        end
        function ideal_BP = ideal_BP_DS_filter(low_freq, high_freq, downsample_rate, n, Fs)
            ind_low  = round(low_freq * n / Fs) + 1;
            ind_high = round(high_freq * n / Fs) + 1;
            ideal_BP = zeros(1, n);
            % Positive freq part
            ideal_BP(ind_low:ind_high - 1) = ones(1, ind_high - ind_low); 
            % Negative freq part
            % ideal_BP(n - ind_high + 1:n - ind_low) = ones(1, ind_high - ind_low);
            % Downsampling
            if downsample_rate < 1
                non_sample_num = round((1 - downsample_rate) * (ind_high - ind_low));
                pos_non_sample_ind = randsample(ind_low:ind_high - 1, non_sample_num);
                % neg_non_sample_ind = n - pos_non_sample_ind + 1;
%                 ideal_BP([pos_non_sample_ind neg_non_sample_ind]) = 0;
                ideal_BP([pos_non_sample_ind]) = 0;
            end
            
        end
        % function gaussian_BP = gaussian_BP_filter(low_freq, high_freq, n, Fs)
            % TODO: finshi gaussian bp filter
            
        % end
    end
end