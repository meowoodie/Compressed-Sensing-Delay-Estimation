function stacked_signal = stack( root_path, file_names )
% Stack
% This function read all the indicated files and stack them into one
% signal, which means it sums the values in each signal bit by bit, and
% does the average over the sum.
    X = [];
    for i=1:length(file_names)
        fprintf('Reading file: %s\n', [root_path '/' file_names{i}]);
        X = [X; transpose(signal_reader([root_path '/' file_names{i}]))];
    end
    stacked_signal = transpose(mean(X));
end

