function validTransition = isElectricDipoleTransition( N1,L1,M1, N2,L2,M2) %#ok<INUSL>
% isElectricDipoleTransition Indicates allowed electric dipole transitions
%   isElectricDipoleTransition( N1,L1,M1, N2,L2,M2) calculates whether the
%   transition between the states |N1,L1,M1> and |N2,L2,M2> obeys the electric
%   dipole transition rules, |L1-L2| = 1 and |M1-M2| <= 1. If these conditions
%   are satisfied, the function returns true, else it returns false.

% Copyright 2009 The MathWorks, Inc.

validTransition = ( abs(L1-L2) == 1 ) && ( abs(M1-M2) <= 1 );