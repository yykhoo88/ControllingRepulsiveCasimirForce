function maxLine = findRadialMaximum( psi )
% findRadialMaximum Calculate the radial line of maximum probability density
%   findRadialMaximum calculates a vector representing an upper bound on the
%   radial probability density. psi is an NxNxN array representing a
%   wavefunction.
%
%   The function returns a N element vector, with each element, i, representing
%   the maximum probability value along all of psi(i,:,:), psi(:,i,:) and
%   psi(:,:,i).
%
%   To calculate :
%
%     We project the maximum of the wavefunction onto the 3 orthogonal planes, 
%     and take the maximum. We now have the maximum surface. We then project the
%     maximum of the plane onto the two orthogonal lines, and again take the
%     maximum. This gives us the line corresponding to the maximum radial
%     probability profile.
%
%   Example :
%
%     For a wavefunction psi and dimension vector dim, plot the radial maximum :
%       maxLine = findRadialMaximum( psi );
%       plot( dim, maxLine);

% Copyright 2009 The MathWorks, Inc.
prob = conj(psi) .* psi;
prob = prob / max(prob(:));

% Project onto the x-y, y-z, and x-z planes
maxProbXY = squeeze(max(prob,[],3));
maxProbYZ = squeeze(max(prob,[],1));
maxProbXZ = squeeze(max(prob,[],2));

% Find the maximum plane projection, then project onto 2 orthogonal lines
maxProbPlane = max(max(maxProbXY,maxProbYZ),maxProbXZ);

maxLine1 = max(maxProbPlane,[],1)';
maxLine2 = max(maxProbPlane,[],2);

% And thus find maximum probability line
maxLine = max(maxLine1,maxLine2); %#ok
