%This program will output the susceptibility for EIT material, for every
%probe frequency omega.
%
%Revision history
%v1.1
%Initial program

function result = EITSusceptibility(var_omega)

%standard constants
CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-6;

%EIT constants
%-Constant series (this gives the y axis)
var_P=1; %transition matrix elements
var_r=1; %atomic injection rate
var_E0=1; %electric field intensity

%-Defining constants
gamma_phase=0; %NOT IN LIST
gamma_a=0.1; %OK
gamma_b=2; %OK
gamma_c=2; %OK
var_phi=5/4*pi; %OK

%-Omega series
omega_ab=2; %NOT IN LIST
omega_ac=0; %NOT IN LIST
omega_cb=omega_ab-omega_ac; %OK, in paper should =2

%-delta series
delta_ab=omega_ab-var_omega; %OK
delta_ac=omega_ac-var_omega; %OK
%{
delta_bc=omega_bc-var_omega;
delta_ba=omega_ba-var_omega;
delta_ca=omega_ca-var_omega;
delta_cb=omega_cb-var_omega;
delta_aa=omega_aa-var_omega;
delta_bb=omega_bb-var_omega;
delta_cc=omega_cc-var_omega;
%}

%-gamma series
gamma_ab=(gamma_a+gamma_b)./2 +gamma_phase; %OK
gamma_ac=(gamma_a+gamma_c)./2 +gamma_phase; %OK
%{
gamma_bc=(gamma_b+gamma_c)./2 +gamma_phase;
gamma_aa=(gamma_a+gamma_a)./2 +gamma_phase;
gamma_bb=(gamma_b+gamma_b)./2 +gamma_phase;
gamma_cc=(gamma_c+gamma_c)./2 +gamma_phase;
gamma_ba=(gamma_b+gamma_a)./2 +gamma_phase;
gamma_ca=(gamma_c+gamma_a)./2 +gamma_phase;
%}
gamma_cb=(gamma_c+gamma_b)./2 +gamma_phase; %OK

%-rho series
rho_aa=0.01; %OK
rho_bb=0.495; %OK
rho_cc=0.495; %OK
%rho_bc=0.5;
rho_cb=0.495; %OK - rho_bb=rho_cc=rho_cb

%computing polarization
var_ReP_1=(delta_ac.*(rho_aa./gamma_a - rho_cc./gamma_c)) - ((abs(rho_cb)./((gamma_cb.^2 + omega_cb.^2).^(1/2))) .* (delta_ac.*cos(var_phi)+ gamma_ac.*sin(var_phi)));
var_ReP_2=(delta_ab.*(rho_aa./gamma_a - rho_bb./gamma_b)) - ((abs(rho_cb)./((gamma_cb.^2 + omega_cb.^2).^(1/2))) .* (delta_ab.*cos(var_phi)- gamma_ab.*sin(var_phi)));
var_ReP = (var_P.^2 .* var_r .* var_E0 ./ CONST.h_bar) .* (var_ReP_1./(gamma_ac.^2+delta_ac.^2)+var_ReP_2./(gamma_ab.^2+delta_ab.^2));

var_ImP_1=(gamma_ac.*(rho_aa./gamma_a - rho_cc./gamma_c)) - ((abs(rho_cb)./((gamma_cb.^2 + omega_cb.^2).^(1/2))) .* (gamma_ac.*cos(var_phi)- delta_ac.*sin(var_phi)));
var_ImP_2=(gamma_ab.*(rho_aa./gamma_a - rho_bb./gamma_b)) - ((abs(rho_cb)./((gamma_cb.^2 + omega_cb.^2).^(1/2))) .* (gamma_ab.*cos(var_phi)+ delta_ab.*sin(var_phi)));
var_ImP = (var_P.^2 .* var_r .* var_E0 ./ CONST.h_bar) .* (var_ImP_1./(gamma_ac.^2+delta_ac.^2)+var_ImP_2./(gamma_ab.^2+delta_ab.^2));

result=(var_ReP+1i*var_ImP)./CONST.epsilon_0./var_E0;
end