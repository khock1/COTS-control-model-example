function [ wmnodiag ] = zerodiag( weights_matrix )
%ZERODIAG Summary of this function goes here
%   Detailed explanation goes here

for i = 1:size(weights_matrix,3)
    for j = 1:size(weights_matrix,1)
        weights_matrix(j,j,i) = 0;
    end
end
wmnodiag = weights_matrix;

end

