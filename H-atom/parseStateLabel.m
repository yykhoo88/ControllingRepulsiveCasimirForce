function [ N, L, M ] = parseStateLabel( stateLabel )
% parseStateLabel Interprets a state label string into the state parameters
%   parseStateLabel calculates the quantum numbers N, L and M for a state from
%   a string representing that state. The state label must be a string of the
%   form 'N(LName)M', where LName is a single character representing the
%   orbital angular momentum (see lookupLNomenclature), and N and M are
%   integers.

% Copyright 2009 The MathWorks, Inc.

% Ensure that stateLabel is a string
if ~ischar(stateLabel)
    error('Wavefunction:invalidArgument', 'stateLabel must be a string');
end


% Attempt to parse the state label.
[ results, count] = sscanf( stateLabel, '%d%c%d');


% Did we manage to pull the three elements out of the state label?
if count ~= 3
    error('Wavefunction:invalidArgument', ...
    'Could not parse the state label, ensure it is of the form ''N(LName)M'' ');
end


%   Extract N, and ensure it is in the valid range
N = results(1);

if N <= 0
    error('Wavefunction:invalidArgument', 'N must be a positive integer');
end


%   Extract L from it character equivilant
LName = results(2);

% An array containg the double representation of the first 4 L states
% (representing L = 0..3)
LDoubles = double(['s' 'p' 'd' 'f']);

% If LName is in the list of the first 4 L state labels
if any( LName == LDoubles )
    % Extract L from the index into LDoubles, by noting that the character
    % LDoubles(i) represents L = i-1.
    L = find( LName == LDoubles ) - 1;
else
    % This maps LName to the alphabetically increasing sequence g,h,i,j,...
    % where 'g' maps to 4.
    L = 4 + LName - double('g');
end

% And ensure L is in the valid range
if L >= N
    error('Wavefunction:invalidArgument', ...
                                'L must be in the range 0 <= L < N');
end


%   Extract M, and ensure it is in the valid range
M = results(3);

if abs(M) > L
    error('Wavefunction:invalidArgument', ...
                                'M must be in the range -L <= M <= +L');
end
