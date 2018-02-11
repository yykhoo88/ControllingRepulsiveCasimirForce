function rScale = calculateHydrogenicWavefunctionBounds(Z,N,L,threshold)
% calculateHydrogenicWavefunctionBounds Find wavefunction's bounding box
%   rScale = calculateHydrogenicWavefunctionBounds(Z,N,L,threshold)
%   calculates the smallest radius (in Bohr radii) where the absolute value 
%   of the wavefunction is not more than the 'threshold' multiplied by the
%   maximum value of the radial wavefunction. Z,N,L are the central
%   nuclear charge, principal quantum number and angular momentum quantum
%   number respectively.

% Copyright 2009 The MathWorks, Inc.

% To calculate the bounding radius we :
%   * Find an rMax such that the absolute value of the radial wavefunction
%     is definitely below the threshold. I.e. ensure that rScale lies in the
%     range 0 -> rMax.
%   * Search from r = rMax towards r = 0 to find the radius, rScale, where the
%     threshold is first crossed.


%   Find rMax > rScale

% Initial value, this is not critical as long as it is >> 0.
rMax = 100;

% Search for an upper limit on rScale, by increasing rMax until the radial
% equation evaluated at rMax is below the one half of the threshold.
done = false;
while ~done
    r = linspace(0,rMax,500);
    R = abs(iRadialSchrodinger(Z,N,L,r));

    % Scale such that the maximum value is 1.
    R = R/max(R);

    % If the wavefunction is well below the threshold at r = rMax.
    if R(end) < 0.5*threshold
        done = true;
    else
        rMax = 2*rMax;
    end
end


% Now the threshold is definitely crossed in the interval r = 0 -> rMax


% Find where the probability crosses the threshold.
threshCrossing = find( R >= threshold, 1, 'last');


% The value of r at which the threshold is first reached, when approaching 
% r=0 from infinity.
rScale = r(threshCrossing);

end


% Function to calculate the (un-normalised) radial analytic solution
% at point r.
function R = iRadialSchrodinger(Z,N,L,r)

% The Laguerre polynomial coefficents
L_coeffs = LaguerreGen(N-L-1, 2*L+1);

% rho := 2Zr/n.a0
rho = 2*Z*r/N;

% R := exp(-rho/2) * rho^L * Laguerre^(2*L+1)_(N-L-1)(rho)
R = polyval( L_coeffs, rho) .* exp(-0.5*rho) .* (rho).^L;
end