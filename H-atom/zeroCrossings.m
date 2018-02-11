function [posCrossings negCrossings] = zeroCrossings(y)
% zeroCrossings Finds the positive and negative zero crossings of a row vector
%   [posCrossings negCrossings] = zeroCrossings(y) returns the indices of 
%   the positive and negative zero crossings of the row vector y.
%
%   Example: 
%
%     Find the zero crossings of the sine function in the range -pi ... 3*pi
%       x = linspace(-pi,3*pi,100);
%       y = sin(x);
%       [posCrossings negCrossings] = zeroCrossings(y);
%
%   Then x(posCrossings) = [0.0317 6.3784]
%   and x(negCrossings) = [3.2051]
%   Compared to the expected [0 2*pi] and [pi] respectively

% Copyright 2009 The MathWorks, Inc.

% If pos(i) is true, y(i) >= 0 etc.
pos = (y >= 0);
neg = (y < 0);

% If negPos(i) is true, there is a positive zero crossing between y(i)
% and y(i+1) etc.
negPos = ( [pos 0] & [0 neg] );
posNeg = ( [neg 0] & [0 pos] );

negPos = negPos(1:end-1);
posNeg = posNeg(1:end-1);

% Convert into lists of indices from boolean array
indices = 1:length(y);
posCrossings = indices(negPos);
negCrossings = indices(posNeg);
