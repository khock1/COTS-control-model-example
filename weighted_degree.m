function B = weighted_degree( A, alpha )
%WEIGHTEDDEGREE Summary of this function goes here
%   A is an array of links, alpha is the scaling parameter
% if alpha=0, output equal to degree
%if alpha =1, output equal to strength
%if alpha=0.5, both are taken into account
%if alpha>1, strength more important than number

B = numel(A)*((sum(A)/numel(A))^alpha);

end

