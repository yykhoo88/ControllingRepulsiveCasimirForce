function [ var_eta2 ] = frequencyOKE( var_eta0, omega, CONST )
%Frequency dependant n2: accepts n0 and omega as input, returns n2

var_xi3=var_xi3_calc( var_eta0, omega, CONST );
%computing the eta2
var_eta2=3 ./ (4 .* var_eta0.^2 .* CONST.epsilon_0 .* CONST.c) .* var_xi3;

end

function var_xi3 = var_xi3_calc( var_eta0, omega, CONST )

%variable defining to calculate var_xi3
var_N=4e28;
var_omega_0=7e15;
var_gamma=0.01 .* var_omega_0;
var_m=9.10938188e-31;
var_d=3e-10;

%D_omega calculation
D_omega=var_omega_0.^2 - omega.^2 - 2 .* 1i .* omega .* var_gamma;
D_neg_omega=var_omega_0.^2 - omega.^2 + 2 .* 1i .* omega .* var_gamma;

%var_xi3 computing
var_xi3=(var_N .* var_omega_0.^2 .* CONST.e.^4) ./ (CONST.epsilon_0 .* var_m.^3 .* var_d.^2 .* D_omega.^3 .* D_neg_omega);
end