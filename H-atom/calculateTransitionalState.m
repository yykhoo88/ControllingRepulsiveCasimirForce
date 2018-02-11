function [psi, theta, phi] = calculateTransitionalState(psiInitial, ...
                                                    psiFinal,t,rabiRatio)
% calculateTransitionalState Calculate wavefunction during a transition.
%   [psi, theta, phi] = calculateTransitionalState(psiInitial,psiFinal,
%   t,rabiRatio) calculates the intermediate wavefunction during a transition 
%   from wavefunctions psiInitial to psiFinal. 
%
%   The function returns the calculated wavefunction, psi, and theta and phi, 
%   the pair of angles uniquely defining the state.
%  
%   - psiInitial and psiFinal are NxNxN arrays, typically generated by 
%     evaluateHydrogenicWavefunction().
%
%   - t is a pseudo time variable, with t=0 representing psi=psiInitial, and 
%     t=1 representing psi=psiFinal.
%
%   - rabiRatio is the ratio of the transition frequency (EInitial-EFinal)/hbar 
%     to the Rabi frequency. Thus, more practically, the rabiRatio represents
%     the number of 'phase beats' per Rabi cycle, or the number of 1/4 phase 
%     beats per transition.
%
%   - theta and phi are angles representing the state. In the Bloch sphere 
%     representation phi can be viewed as the azimuthal angle and theta as the 
%     inclination angle. Here theta=0 represents psi=psiInitial and  theta=pi 
%     represents psi=psiFinal.  

% Copyright 2009 The MathWorks, Inc.

% For a two state system, after applying the rotating wave approximation :
% psi = psiInitial * cos(Omega*t) * exp(-i*EInitial*t/hbar)
%     + psiFinal   * sin(Omega*t) * exp(-i*EFinal*t/hbar)
% Where Omega is the Rabi frequency.
%
% As any observable is invariant under an overall phase change of the 
% wavefunction, we phase shift by EInitial*t/hbar to get :
% psi <= psiInitial * cos(Omega*t) +
%        psiFinal   * sin(Omega*t) * exp(i*(EInitial-EFinal)*t/hbar)
% 
% We now scale t -> t' such that Omega=0..pi/2 as t'=0..1, then:
% psi <= psiInitial * cos(0.5*theta) +
%        psiFinal   * sin(0.5*theta) * exp(i*phi)
% Where theta = (pi)*t', phi = 0.5*theta*rabiRatio, and
% rabiRatio = ((EInitial-EFinal)/hbar) / Omega

% Note that phi can be viewed as the azimuthal angle and theta as the 
% inclination angle on the Bloch sphere representing the initial and final
% states.
theta = (pi)*t;
phi = theta*rabiRatio;

psi = psiInitial * cos(0.5*theta) ...
    + psiFinal   * sin(0.5*theta)*exp(1i*phi);

