function [ combination ] = combine_pair( list )
% COMBVEC_OCTAVE
    combination = [];
    for i=1:length(list)
        for j=i+1:length(list)
            combination = [combination; [list(i), list(j)]];
        end
    end
    combination = combination';
end

