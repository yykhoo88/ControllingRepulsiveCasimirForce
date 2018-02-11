function [psi dim] = calculateHydrogenicWavefunction( N, L, M, varargin)
% calculateHydrogenicWavefunction Evaluates a hydrogen like wavefunction.
%   calculateHydrogenicWavefunction computes a hydrogen like wavefunction on a
%   three dimensional grid.
%
%   The function returns a 3 dimensional array (size rPoints X rPoints X
%   rPoints), psi, containing the wavefunction and an rPoints element vector,
%   dim, mapping the (i,j,k) element of psi to a point in space
%   [dim(i), dim(j), dim(k)]. 
%
%   Syntax :
%
%     [psi dim] = calculateHydrogenicWavefunction( N, L, M)
%       Calculates a hydrogen wavefunction for Z=1 (where Z is the nuclear 
%       charge in units of e, the charge on an electron). N is the principal 
%       quantum number (equivalent to the shell in the Bohr model), N must be 
%       >= 1. L is the total angular momentum, |L| must be < N. 'M' is the 
%       projection of the angular momentum vector onto the z-axis, |M| must be 
%       <= L. rPoints, the number of points along each dimension of the
%       wavefunction defaults to 70. The scale of the axes (dim) is chosen such
%       that the value of the wavefunction on the boundary of the volume is no
%       more than 1% of wavefunction's peak value.
%
%     [psi dim] = calculateHydrogenicWavefunction( N, L, M, rPoints)
%       Calculates a hydrogen wavefunction, as above, but the caller specifies
%       rPoints, the number of points along each dimension of the axes.
%
%     [psi dim] = calculateHydrogenicWavefunction( N, L, M, rPoints, rScale)
%       Calculates a hydrogen wavefunction, as above, but the caller specifies
%       rScale, the radial extent of the axes. The wavefunction is evaluated
%       at rPoints equally spaced points between -rScale and +rScale for the x,
%       y, and z axes. rScale is specified in Bohr radii.
%
%     [psi dim] = calculateHydrogenicWavefunction( N, L, M, rPoints, rScale, Z)
%       Calculates a hydrogen wavefunction, as above, but the caller specifies
%       Z, the central nuclear charge, in units of e.
%
%   Examples :
%
%     Calculate the hydrogen 2p0 wavefunction, and plot it :
%       [psi dim] = calculateHydrogenicWavefunction( 2, 1, 0);
%       plotPsi( psi, dim);
%
%     Calculate the hydrogen 2p0 wavefunction evaluated at 100 points along each
%     axis, and plot it :
%       [psi dim] = calculateHydrogenicWavefunction( 2, 1, 0, 100);
%       plotPsi( psi, dim);
%
%     Calculate the Beryllium 3+ ion's 1s0 wavefunction, and compare it to the
%     hydrogen 1s0 wavefunction. We use 100 points along each axis and with the axes limits being +/- 1.6 Bohr radii
%       [psi_Be dim] = calculateHydrogenicWavefunction( 1, 0, 0, 70, 1.6, 5);
%       [psi_H dim] = calculateHydrogenicWavefunction( 1, 0, 0, 70, 1.6, 1);
%       subplot(2,1,1);
%       plotPsi( psi_H, dim, 0.05, 0.5, 1.6);
%       title('Hydrogen''s 1s0 state');
%       subplot(2,1,2);
%       plotPsi( psi_Be, dim, 0.05, 0.5, 1.6);
%       title('Beryllium''s 3+ 1s0 state');

% Copyright 2009 The MathWorks, Inc.

% The following code in this file uses atomic units, where a0 = 1, 
% hbar = 1 and e = 1.


%   Check the input arguments are sane

% Do we have a plausible number of arguments.
if nargin < 3 || nargin > 6
    error('Wavefunction:invalidArgument', 'Incorrect number of arguments');
end

% Ensure the specified quantum state exists
if N < 1 || N ~= round(N)
    error('Wavefunction:invalidArgument', 'N must be a positive integer');
end

if L >= N || L ~= round(L)
    error('Wavefunction:invalidArgument', ...
                'L must be an integer in the range 0 <= L < N');
end

if abs(M) > L || M ~= round(M)
    error('Wavefunction:invalidArgument', ...
                'M must be an integer in the range -L <= M <= +L');
end


% Pick arguments out of varargin and set defaults

if nargin < 6
    % The default nuclear charge is 1e (hydrogen)
    Z = 1;
else
    Z = varargin{3};

    % Check provided Z is reasonable
    if Z <= 0
        error('Wavefunction:invalidArgument', 'Z must be positive');
    end
end

if nargin < 5
    % Set rScale to fully encompass the wavefunction to (at least) the 1% level
    threshold = 0.01;
    rScale = calculateHydrogenicWavefunctionBounds( Z, N, L, threshold);
else
    rScale = varargin{2};

    % Check provided rScale is reasonable
    if rScale <= 0
        error('Wavefunction:invalidArgument', ...
                    'rScale must be positive');
    end
end

if nargin < 4
    % Set the default value for rPoints
    rPoints = 70;
else
    rPoints = varargin{1};

    % Check provided rPoints is reasonable
    if rPoints  < 1 || rPoints  ~= round(rPoints)
    error('Wavefunction:invalidArgument', 'rPoints must be a positive integer');
    end
end



%   Initialise variables and preallocate arrays

dim = linspace(-rScale,rScale,rPoints);

psi = zeros(rPoints,rPoints,rPoints);


%   Calculate polynomial, physical and normalisation coefficients.

% The term 2Z/(N.a0) occurs frequently in the analytic solution, so is
% precalculated. N.B. a0 = 1 in atomic units
Z_Na = 2*Z/N;

% The spherical harmonic normalisation factor. The spherical harmonics are
% defined : Yml(theta,phi) = Pml(cos(theta)) * exp(i*M*phi)
%           * ( (2*L+1)/(4*pi) * (L-M)!/(L+M)! )^0.5
% Where the last term is the constant, YNorm, calculated below, and Pml is
% the associated Legendre function.
YNorm = ( (2*L+1)*factorial(L-M) / (4*pi*factorial(L+M)) )^0.5;

% Precompute the coefficents of the polynomial part of the associated Legendre
% function
Pml_polyCoeffs = iPrecomputeAssocLegendreFunc(L,M);


% The overall wave-function normalisation coefficent. The hydrogenic
% analytic solution is defined :
% psi = exp(-rho/2) * rho^L * L^(2*L+1)_(N-L-1)(rho) * Ylm(theta,phi) 
%       * ( (2/(N*a0))^3 * (N-L-M)! / (2*N*(N+L)! ) )^0.5
% Where the last term is the constant, psiNorm, calculated below, rho =
% 2r/(N*a0) = r*Z_Na, Ylm is the (normalised) spherical harmonic, and L is
% the generalised Laguerre polynomial.
psiNorm = Z_Na^(3/2) * ( factorial(N-L-1) / (2*N*factorial(N+L)) )^0.5;

% Precompute the generalised Laguerre polynomial coefficents.
L_coeffs = LaguerreGen(N-L-1, 2*L+1);



%   Now calculate the wave-function at every point on the grid.

% Record the time at which the computation starts, so that we can
% periodically provide the user with a progress update.
tLastProgressUpdate = cputime;
fprintf('00.0%%\n');

% For each i,j, we calculate psi for a vector of k values. 
k = 1:rPoints;
for i = 1:rPoints
    for j = 1:rPoints
        % Calculate each point's position in (standard) spherical
        % coordinates. N.B. cart2sph returns (pi/2 - theta) in the standard
        % notation.
        [ phi, thetaConj, r] = cart2sph( dim(i), dim(j), dim(k));
        theta = pi/2 - thetaConj;

        % Evaluate the normalised spherical harmonic.
        Y = YNorm * exp(1i*M*phi) .* (1-cos(theta).^2).^(abs(M)/2) ...
                 .* polyval( Pml_polyCoeffs, cos(theta));
        
        % Evaluate the radial part of the analytic solution.
        rho = Z_Na*r;
        R = polyval( L_coeffs, rho) .* exp(-0.5*rho) .* (rho).^L;
        
        % Finally, compose the complete, normalised, solution. 
        psi(i,j,k) = psiNorm * Y .* R;
    end
    
    % If more than 1 second has passed since the last progress update, and
    % we have not just finished the last iteration, print how far we are
    % through the loop.
    if (cputime-tLastProgressUpdate) > 1 && i ~= rPoints
        % Delete the last progress update, and print how far we are through the
        % array of i points we are (in percent).
        fprintf('\b\b\b\b\b\b%04.1f%%\n', 100*i/rPoints);
        tLastProgressUpdate = cputime;
    end
end

% Finally, delete the previously printed progress update.
fprintf('\b\b\b\b\b\b');

end % function calculateHydrogenicWavefunction



%-------------------------------------------------------------------------------
%
%-------------------------------------------------------------------------------

%   Precompute the polynomial part of the associated Legendre function.
% To evaluate the associated Legendre function Plm(x), one needs to
% evaluate the polynomial, and multiply by (1-x^2)^(M/2) :
%   Plm(x) = (1-x^2)^(M/2) * polyval( Pml_polyCoeffs, x)
function Pml_polyCoeffs = iPrecomputeAssocLegendreFunc( L, M)
    % Calculate the coefficients of the Legendre polynomial of order L.
    Pl = LegendrePoly(L);

    % The associated Legendre function, Plm, is related to the Legendre
    % polynomial Pl : Plm = (-1)^M * (1-x^2)^(M/2) * (d^M/d.x^M) Pl(x),
    % for M >= 0. Here we just calculate the polynomial part.
    
    % Differentiate Pl |M| times
    Ptmp = Pl;
    for a = 1:abs(M)
        Ptmp = polyder(Ptmp);
    end
 
    % Multiply by the Condon–Shortley phase.
    Pml_polyCoeffs = (-1)^abs(M) * Ptmp;

    % Extend for M < 0
    % P-ml = Pml * (-1)^M * (L-M)!/(L+M)!
    if M < 0
        Pml_polyCoeffs = Pml_polyCoeffs * (-1)^abs(M) * ...
                            factorial(L-abs(M))/factorial(L+abs(M));
    end
end % function iPrecomputeAssocLegendrePoly
