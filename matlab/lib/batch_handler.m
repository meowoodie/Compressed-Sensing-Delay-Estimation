function [ result ] = batch_handler( ...
    x1, x2, window_size, ...
    func_handle) 
% Batch Handler
% 

    %% Cut the signals into multiple segments by the window size

    % The number of the segments of windows
    b = floor(length(x1)/window_size);
    % Length of the signal that we're going to use
    n = b * window_size;
    % Reshape the signals into 2D matrix,
    x1 = reshape(x1(1:n), window_size, b);
    x2 = reshape(x2(1:n), window_size, b);
    % Whitening
    x1 = bsxfun(@times, x1, 1./max(abs(x1)));
    x2 = bsxfun(@times, x2, 1./max(abs(x2)));
    % A row of the matrix is a segment of the raw signal (x(i,:))
    x1 = transpose(x1);
    x2 = transpose(x2);

    %% Do func_handle in batches with the divided segments of the signal
    result = zeros(1,b);
    for i=1:b
        signal_a = x1(i,:);
        signal_b = x2(i,:);
        % Taper
        sigma = window_size/6;
        mean  = window_size/2;
        gaussian_window = normpdf((1:window_size), mean, sigma);
        signal_a = signal_a .* gaussian_window;
        signal_b = signal_b .* gaussian_window;
        % Do callback function
        % Note: If you have other paremeters for the func_handle,
        %       you simply need to wrap your funtion handle into 
        %       an anonymous function where the parameters are set,
        %       e.g. func_handle = @(signal_a, signal_b) ...
        %            your_function(signal_a, signal_b, your_paras)
        result(i) = func_handle(signal_a, signal_b);
    end

end

