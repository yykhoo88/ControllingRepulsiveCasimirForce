function result=test(omega)
CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-6;
CONST.e=1.602176565e-19;
%omega_0 is a stupid dummy variable.

%initializing As2S3 glass
mu=1+(-3.36e-10); %susceptibility by Z. CIMPL et al phys. stat. sol. 41, 535 (1970)

%refraction index
%variables
var_E_d=26 .* CONST.e ./CONST.h_bar;
var_E_s=4.1 .* CONST.e./CONST.h_bar; %As2Se3 value
var_gamma = 0.01.*var_E_d;

%computing
refraction_index_squared = (var_E_d .* var_E_s ./ (var_E_s.^2 - omega.^2 - (1i  .* omega .* var_gamma) ))+1;

result=refraction_index_squared;
end