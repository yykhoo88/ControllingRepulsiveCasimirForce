function result=As2S3(omega,omega_0,vbr_type,CONST)

%omega_0 is a stupid dummy variable.

%initializing As2S3 glass
mu=1+(-3.36e-10); %susceptibility by Z. CIMPL et al phys. stat. sol. 41, 535 (1970)

%refraction index
%variables
var_E_d=26 .* CONST.e;
var_E_s=2.12 .* CONST.e;
%computing
refraction_index_squared = (var_E_d .* var_E_s ./ (var_E_s.^2 - (CONST.h_bar .* omega).^2)) + 1; %T.I. Kosa et al. / Nonlinear optical properties of silver-doped As2S z
refraction_index = sqrt (refraction_index_squared);


%returning appropriate variable
    if vbr_type == 1
        result=refraction_index.^2./mu;
    elseif vbr_type == 2
        result=mu;
    elseif vbr_type == 3
        result=frequencyOKE( refraction_index, omega, CONST );
    end
end