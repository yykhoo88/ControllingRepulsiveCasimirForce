function rBB = findWavefunctionsBoundingRadius( probThresh, dim, psi1, psi2)
% findWavefunctionsBoundingRadius Finds the bounding radius of wavefunctions
%   findWavefunctionsBoundingRadius calculates the maximum extent of one
%   wavefunction, or a combination of two wavefunctions, at a given
%   (probability) threshold.
%
%   Syntax :
%
%     rBB = findWavefunctionsBoundingRadius( probThresh, dim, psi1)
%       Finds the bounding radius of the wavefunction psi1 at probability
%       threshold probThresh, where probThresh is expressed as a fraction of
%       the peak probability density. psi1 is an NxNxN array containing the
%       wavefunction. dim is an N element vector mapping the (i,j,k) element of
%       psi1 to a point in space [dim(i), dim(j), dim(k)].
%
%     rBB = findWavefunctionsBoundingRadius( probThresh, dim, psi1, psi2)
%       Finds the bounding radius of any superposition of psi1 and psi2 at
%       probability threshold probThresh. psi1 and psi2 are wavefunction arrays
%       as described above.
%
%   Example :
%
%     Find the wavefunction for N=2,L=1,M=-1, calculate the bounding radius, and
%     plot it, with the axes scaled to just fit the wavefunction.
%       psiList = getPsiList();
%       [psi dim] = getPsiFromNLM(psiList,2,1,-1);
%       rBB = findWavefunctionsBoundingRadius( 0.05, dim, psi);
%       plotPsi(psi, dim, 0.05, 0.5, rBB);

% Copyright 2009 The MathWorks, Inc.

if nargin < 3 || nargin > 4
    error('Wavefunction:invalidArgument', 'Incorrect number of arguments');
end

% If we are dealing with 2 wavefunctions:
if nargin == 4
    % Considering all possible relative phases, the largest probability density
    % is likely similar to the maximum at each point on the grid of :
    %   * psi1
    %   * psi2
    %   * abs(psi1) + abs(psi2)
    %
    % So we calculate the probability density corresponding to each of these
    % possibilities, and then take the maximum.

    maxLine1 = findRadialMaximum(psi1);
    maxLine2 = findRadialMaximum(psi2);
    maxLine3 = findRadialMaximum( abs(psi1) + abs(psi2) );
    
    maxLine = max([ maxLine1(:) maxLine2(:) maxLine3(:) ], [], 2);
    
else % We only have one wavefunction to consider.
    maxLine = findRadialMaximum(psi1);
end



% maxLine is now a vector representing the peak radial probability density.
% The last step is to threshold this line, and find the
% first point, approaching from a large radius, at which the threshold is 
% crossed.


% Find where the probability crosses the threshold. Note that the dimension
% vector dim ranges from -r to r, so we search in from -r and from +r towards
% r=0.
threshCrossing(1) = find( maxLine >= probThresh, 1, 'first');
threshCrossing(2) = find( maxLine >= probThresh, 1, 'last');

% Find the radii at which the threshold is crossed
rCrossing = abs(dim(threshCrossing));


% A small offset is added to ensure that the given bound fully encompasses
% the probability isosurface.
rBB = 0.1+max(rCrossing);


