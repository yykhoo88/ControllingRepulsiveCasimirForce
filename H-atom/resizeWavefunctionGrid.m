function [psiScaled dimScaled] = ...
                        resizeWavefunctionGrid(psiUnscaled, dimUnscaled,N)
% resizeWavefunctionGrid Resize wavefunctions onto a uniform grid
%   [psiScaled dimScaled] = resizeWavefunctionGrid(psiUnscaled, 
%   dimUnscaled) interpolates each of the wavefunctions in the cell array
%   psiUnscaled (with corresponding axes in the cell array dimUnscaled) 
%   onto a uniform NxNxN grid. The grid is chosen to be sufficently large so as
%   to encompass all of the volumes described by input wavefunctions. Volumes of
%   the new grid not described by the original wavefunction are set to zero.
%
%   The function returns psiScaled, a cell array of NxNxN wavefunctions, and
%   dimScaled, an N element dimension vector such that each element (i,j,k) in
%   each entry in psiScaled corresponds to [x y z] = [dimScaled(i) dimScaled(j)
%   dimScaled(k)].
%
%   Example :
%     Rescale the 1s0 and 2p0 wavefunctions onto the same 70x70x70 grid, and
%     plot them :
%       psiList = getPsiList();
%       [psi_1 dim_1] = getPsiFromNLM( psiList, 1, 0, 0);
%       [psi_2 dim_2] = getPsiFromNLM( psiList, 2, 1, 0);
%       [psiScaled dimScaled] = resizeWavefunctionGrid({psi_1, psi_2},...
%                                                      {dim_1, dim_2}, 70);
%       plotPsi(psiScaled{1}, dimScaled);
%       plotPsi(psiScaled{2}, dimScaled);

% Copyright 2009 The MathWorks, Inc.

%   Check input parameters are sane

if N < 1 || N ~= round(N)
    error('Wavefunction:invalidArgument', 'N must be a positive integer');
end

if size(psiUnscaled) ~= size(dimUnscaled)
    error('Wavefunction:invalidArgument', ...
          'Input arguments psiUnscaled and dimUnscaled must be the same size');
end

% Check that each of the wavefunctions in psiUnscaled has a correctly sized
% dimension vector in dimUnscaled
for i = 1:numel(psiUnscaled)
    if ~isequal( size(psiUnscaled{i}), [1 1 1]*length(dimUnscaled{i}) )
        error('Wavefunction:invalidArgument', ...
            ['The size of wavefunction in psiUnscaled{%1$d} is not '... 
            'consistent with the length of the dimension vector in' ...
            'dimUnscaled{%1$d}'] , i);
    end
end


% Check for the trivial solution; only one wavefunction already on the
% correct size grid.
if numel(psiUnscaled) == 1 && numel(dimUnscaled{i}) == N
    psiScaled = psiUnscaled;
    dimScaled = dimUnscaled{1};
    return;
end


%   Generate the new grid

% Arrays containing the lower and upper x values in each grid
dimMax = cellfun(@(x)(max(x)),dimUnscaled);
dimMin = cellfun(@(x)(min(x)),dimUnscaled);

% The new dimension vector, spanning the range of all the vectors in dimUnscaled
dimScaled = linspace( min(dimMin), max(dimMax), N);


%   Rescale the wavefunctions

psiScaled = cell(size(psiUnscaled));

% Generate the meshgrid we need for interp3
[xi yi zi] = meshgrid(dimScaled, dimScaled, dimScaled);

for i = 1:numel(psiUnscaled)

    if isequal( dimScaled, dimUnscaled{i})
        % If our wavefunction is provided on the correct grid, life is easy.
        psiScaled{i} = psiUnscaled{i};
    else
        % Otherwise we use *linear interpolation (as xi,yi,zi are equally spaced
        % and monotonic), with all points not described by the unscaled 
        % wavefunction set to 0.
        EXTRAPOLATE_TO = 0;
        psiScaled{i} = ...
                interp3(dimUnscaled{i}, dimUnscaled{i},  dimUnscaled{i}, ...
                    psiUnscaled{i}, xi, yi, zi, '*linear', EXTRAPOLATE_TO);   
    end
end
