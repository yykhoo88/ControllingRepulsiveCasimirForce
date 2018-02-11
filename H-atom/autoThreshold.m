function thresholds = autoThreshold( psi )
% autoThreshold Estimate wavefunction iso-surface thresholds for visual effect
%   thresholds = autoThreshold( psi ) calculates reasonable probability 
%   density inner and outer isosurface values. psi is an NxNxN array containing
%   the wavefunction.
%
%   The function returns a two element vector, the first element of which is the
%   outer isosurface value, the second element being the inner isosurface
%   value. The inner and outer isosurface values are expressed as a fraction of
%   the wavefunction's peak probability density.
%
%   Example :
%   
%     Plots the N=3,L=2,M=0 wavefunction.
%       psiList = getPsiList();
%       [psi dim] = getPsiFromNLM( psiList, 3, 2, 0);
%       thresholds = autoThreshold(psi);
%       plotPsi( psi, dim, thresholds(1), thresholds(2));

% Copyright 2009 The MathWorks, Inc.

% To calculate the thresholds :
%   * We first find the maximum radial line.
%   * We find the location of the local maxima by looking for negative zero
%     crossings in the first derivative.
%   * We set the inner threshold to be half of the largest local maxima.
%   * We set the outer threshold to be half of the smallest local maxima, or, if
%     the smallest local maxima is very close in size to the largest local
%     maxima we set the outer threshold to 0.05 .


% Calculate the maximum radial line
maxLine = findRadialMaximum(psi);

% Calculate the first derivative
dydx = diff(maxLine)';

% Pad to bring dydx to the same length as maxLine
dydx = [dydx dydx(end)];

% Calculate negative going zero crossings in the derivative.
[pc, nc] = zeroCrossings(dydx);

% Find values of maxima by noting that a local maxima is defined by a
% negative zero-crossing of the derivative.
maxima = maxLine(nc);

% Find smallest maxima
minIndex = (maxima == min(maxima));
minMax = maxima(minIndex);
thresholds(1) = 0.5*minMax(1);

% The largest maxima has already been scaled to 1
thresholds(2) = 0.5;
    
% If there is only one local maximum value (i.e. our thresholds are close 
% to identical), set the outer threshold to be smaller.
if thresholds(1) >= 0.9*thresholds(2)
    thresholds(1) = 0.05;
end