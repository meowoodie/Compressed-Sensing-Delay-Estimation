function Rs = batch_filters( x1, x2, filters )
% Batch filters
    
    % Parameters
    % - Cost functions with each of the downsampling rates
    Rs = [];   
    % - The number of all of the downsampling rates
    times = size(filters, 1); 
    
    % Calculate compressed-sensing cost function for each of the
    % downsampling rates
    for i=1:times
        disp(size(filters(i,:)));
        Rs = [ Rs; ...
            compressed_sensing.sub_cost_function(x1, x2, filters(i,:))];
    end
end

