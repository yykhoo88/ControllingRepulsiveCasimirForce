function simpleAnimateTransition( initialState, finalState)
% simpleAnimateTransition Animate a transition between given states
%   simpleAnimateTransition animates a transition between the given initial
%   and final states. The states are specified as 'state labels', strings of the
%   form 'N(LName)M', where N and M are integers, and (LName) is a character
%   representing the angular momentum state (see lookupLNomenclature). Examples
%   of states in this nomenclature are N=1,L=0,M=0 -> '1s0' and N=5,L=3,M=-1 ->
%   '5d-1'.
%
%   Example :
%
%     Animate the transition between the states N=1, L=0, M=0 and N=2, L=1, M=0
%     states :
%       simpleAnimateTransition( '1s0', '2p0')

% Copyright 2009 The MathWorks, Inc.

% Convert from the state labels to the state parameters.
[ N1, L1, M1] = parseStateLabel( initialState );
[ N2, L2, M2] = parseStateLabel( finalState );


% Calculate the wavefunctions.
fprintf('Calculating wavefunctions ...\n');
[psi1 dim1] = calculateHydrogenicWavefunction( N1, L1, M1);
[psi2 dim2] = calculateHydrogenicWavefunction( N2, L2, M2);


% Scale the wavefunctions onto the same grid.
[psiScaled dimScaled] = resizeWavefunctionGrid({psi1, psi2}, ...
                                               {dim1, dim2}, length(dim1));


psiInitial = psiScaled{1};
psiFinal = psiScaled{2};


% Finally, run the animation.
fprintf('Animating transition ...\n');

tVec = linspace(0,1,100);
animateTransition( tVec, dimScaled, psiInitial, psiFinal);
