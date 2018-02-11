function name = lookupLNomenclature(L)
% lookupLNomenclature Returns name for given angular momentum state
%   name = lookupLNomenclature(L) finds the standard name for the angular
%   momentum state L. 
%
%   The function returns a cell array of strings, with the size of the returned
%   cell array being the same as the argument L.
%
%   - L is the (array of) angular momentum state(s). (Each element of) L must be
%     in the range 0 <= L <= 12, as the nomenclature is undefined past L=12.
%
%   Examples :
%
%   lookupLNomenclature(0) returns {'s'}
%   lookupLNomenclature(3) returns {'f'}
%   lookupLNomenclature([0 1 2]) returns {'s','p','d'}

% Copyright 2009 The MathWorks, Inc.

if min(L) < 0
    error('Wavefunction:invalidArgument','L must be >= 0');
end

if max(L) > 12
    error('Wavefunction:invalidArgument', ...
        'L must be < 12, as the nomenclature is undefined past L=12 -> "o"');
end


% Initialise the cell array to store the results in
name = cell(size(L));

% For L=0..3, we use the lookup table LName. For L >= 4, we use
% alphabetical ordering continuing from 'f': g,h,i,j...

LName = ['s','p','d','f'];

% If an element in useLookupTable is true, we index into LName for the
% respective name, else we use alphabetical ordering
useLookupTable =  L(:) < 4;

for i = 1:numel(L)
    if(useLookupTable(i))
        name{i} = LName( L(i) + 1 );
    else
        % For L=4, this returns 'g'.
        name{i} = char( double('g') + L(i)-4 );
    end
end

