function psiList = generateWavefunctionList( varargin )
% generateWavefunctionList Calculates a list of wavefunctions
%   generateWavefunctionList calculates hydrogenic wavefunctions on a 3d grid
%   for a set of states.
%
%   The function returns a structure containing the fields psi, dim, N, L, M and
%   Z. psi is an rPoints X rPoints X rPoints array containing the wavefunction.
%   dim is a vector with rPoints elements mapping the (i,j,k) element of psi to
%   a point in space [dim(i), dim(j), dim(k)]. N, L and M are the state
%   parameters of the wavefunction. Z is the central nuclear charge the
%   wavefunction was evaluated with.
%
%   Syntax :
%
%     psiList = generateWavefunctionList()
%       Calculates wavefunctions for all states with N = 1..4. The wavefunctions
%       are evaluated at rPoints = 70 points along each axis - this is a good
%       compromise between the wavefunction fidelity and computational effort.
%       The axes bounds are chosen such that the value of the wavefunction on 
%       the boundary of the volume is no more than 1% of wavefunction's peak
%       value.
%
%     psiList = generateWavefunctionList( NValues, LValues, MValues)
%       Calculates wavefunctions for all valid combinations of state parameters
%       specified in the arrays NValues, LValues, MValues. For example, if
%       NValues = [1 2 3], LValues = [1 2], MValues = [0 -1], the generated
%       wavefunctions have (N,M,L) = (2,1,0), (2,1,-1), (3,1,0), (3,1,-1),
%       (3,2,0), (3,2,-1). The axes bounds and the number of points along each
%       axis are chosen as above. 
%
%     psiList = generateWavefunctionList( NValues, LValues, MValues, rPoints)
%       Calculates the wavefunctions as above, but with a specified number of
%       points along each axis, rPoints.
%
%     psiList = generateWavefunctionList( NValues, LValues, MValues, rPoints, 
%                                                           thresh)
%       Calculates the wavefunctions as above, but the axes bounds are chosen
%       such that the value of the wavefunction on the boundary of the volume
%       is no more than the fraction thresh of wavefunction's peak value.
%
%     psiList = generateWavefunctionList( NValues, LValues, MValues, rPoints, 
%                                                           thresh, Z)
%       Calculates the wavefunctions as above, but with central nuclear charge
%       Z.
%
%
%   Examples :
%       
%     Evaluate the 6 wavefunctions 2p0, 2p-1, 3p0, 3p-1, 3d0, 3d-1 and plot
%     them in a grid.
%
%       psiList = generateWavefunctionList( [2 3], [1 2], [-1 0]);
%       for i = 1:numel(psiList)
%           subplot(2,3,i);
%           LName = lookupLNomenclature(psiList(i).L);
%           title(sprintf('%d%s%d\n', psiList(i).N, LName{1}, psiList(i).L));
%           plotPsi( psiList(i).psi, psiList(i).dim);
%       end

% Copyright 2009 The MathWorks, Inc.

%   Parse the input arguments

% Do we have a plausible number of arguments.
if ~any( nargin == [0 3 4 5 6] )
    error('Wavefunction:invalidArgument', 'Incorrect number of arguments');
end

if nargin == 0
    % Set the default values of NValues,LValues,MValues to produce all of the
    % wavefunctions with N = 1..4
    
    NValues = 1:4;
    LValues = 0:3;
    MValues = -3:3;
else
    NValues = varargin{1};
    LValues = varargin{2};
    MValues = varargin{3};

    % Ensure that all of the specified values of N are in the plausible ( >= 1 )
    if any( NValues < 1 | round(NValues) ~= NValues)
        error('Wavefunction:invalidArgument', ...
                'All of the elements of NValues must be positive integers');
    end

    % Ensure that all of the specified values of L are plausible
    % ( >= 0 and integer ).
    if any( LValues < 0 | round(LValues) ~= LValues )
        error('Wavefunction:invalidArgument', ...
                'All of the elements of LValues must be non-negative integers');
    end

    % Ensure that all of the specified values of M are plausible ( integer )
    if any( round(MValues) ~= MValues )
        error('Wavefunction:invalidArgument', ...
                'All of the elements of MValues must be integers');
    end
end

if nargin < 4
    % Set the default value of rPoints to 70 as this is a good compromise
    % between the wavefunction fidelity and computational effort.
    rPoints = 70;
else
    rPoints = varargin{4};

    % Ensure that rPoints is in the valid range.
    if rPoints < 1 || rPoints ~= round(rPoints)
        error('Wavefunction:invalidArgument', ...
                'rPoints must be a positive integer');
    end
end

if nargin < 5
    % Set the default value of thresh to 1% as this gives a resonable
    % reproduction of the wavefunction without leaving lots of 'white space' in
    % the wavefunction grid.
    thresh = 0.01;
else
    thresh = varargin{5};

    % Ensure that thresh is a fraction in the range ( 0, 1)
    if thresh <= 0 || thresh >= 1
        error('Wavefunction:invalidArgument', ...
                'thresh must be greater than 0 but less than 1');
    end
end

if nargin < 6
    % The default nuclear charge is 1e (hydrogen)
    Z = 1;
else
    Z = varargin{6};

    % Ensure that the nuclear charge is positive.
    if Z <= 0
        error('Wavefunction:invalidArgument', ...
                'Z must be a positive number');
    end
end



%   Now start calculating the wavefunctions

fprintf('Preparing to calculate wavefunctions\n\n');


% Instantiate a blank structure for the wavefunction list.
psiList = struct( 'psi', {}, ...
                  'dim', {}, ...
                  'N', {}, ...
                  'L', {}, ...
                  'M', {} );


% Loop counter, to keep track of current index in psiList
i = 1;

% Iterate through all legal combinations of NValues, LValues and MValues.
for N = NValues(:)'
    % L can range from 0 to N-1
    LLegal = 0:(N-1);

    % For all given LValues that are legal values of L (for this N) 
    for L = intersect( LLegal, LValues(:)')
        % M can range from -L to +L
        MLegal = -L:+L;

        % For all given MValues that are legal values of M (for this L)
        for M = intersect( MLegal, MValues(:)')
            % Create a state label, of the form N,(L Name), M
            LName = lookupLNomenclature(L);
            label = sprintf('%d%c%d',N,LName{1},M);

            fprintf('%d : Calculating %s wavefunction\n',i,label);

            % Calculate the grid scaling
            rScale = calculateHydrogenicWavefunctionBounds( Z, N, L, thresh);
            
            % Calculate the wavefunction
            [psi dim] = calculateHydrogenicWavefunction( N, L, M, ...
                                                        rPoints, rScale, Z);

            % Save the wavefunction, it's dimension vector, and the state
            % properties to the psiList structure.
            psiList(i).psi = psi;
            psiList(i).dim = dim;
            psiList(i).N = N;
            psiList(i).L = L;
            psiList(i).M = M;
            psiList(i).Z = Z;
            
            i = i+1;
        end
    end
end

% If no valid combinations of N,L,M were found in NValues, LValues, MValues
if i==1
    warning('Wavefunction:noValidStatesSpecified', ...
                ['No valid combinations of N,L,M were found in '...
                 'NValues, LValues, MValues']);
end
