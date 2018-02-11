function simplePlotPsi( state )
% simplePlotPsi Plot a given hydrogen wavefunction
%   simplePlotPsi( state ) calculates and plots the wavefunction represented by
%   the state string 'state'. The states are specified as 'state labels',
%   strings of the form 'N(LName)M', where N and M are integers, and (LName) is
%   a character representing the angular momentum state
%   (see lookupLNomenclature). Examples of states in this nomenclature are
%   N=1,L=0,M=0 -> '1s0' and N=5,L=3,M=-1 -> '5d-1'.

% Copyright 2009 The MathWorks, Inc.

% Convert from the state label to the state parameters.
[ N, L, M] = parseStateLabel( state );


% Calculate the wavefunction.
fprintf('Calculating wavefunction ...\n');
[psi dim] = calculateHydrogenicWavefunction( N, L, M);

plotPsi( psi, dim);
