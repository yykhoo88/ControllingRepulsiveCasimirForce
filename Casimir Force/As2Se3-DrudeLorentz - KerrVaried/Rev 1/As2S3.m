function result=As2S3(omega,vbr_type,CONST)

%omega_0 is a stupid dummy variable.

%initializing As2S3 glass
mu=1+(-3.36e-10); %susceptibility by Z. CIMPL et al phys. stat. sol. 41, 535 (1970)

%refraction index
%variables
var_E_d=26 .* CONST.e;
var_E_s=4.1 .* CONST.e; %As2Se3 value
var_gamma = 0.01 .* var_E_s ./ CONST.h_bar;

%computing
refraction_index_squared = (var_E_d .* var_E_s ./ (var_E_s.^2 - (CONST.h_bar .* omega).^2 - (1i .* CONST.h_bar.^2 .* omega .* var_gamma) )) + 1; %T.I. Kosa et al. / Nonlinear optical properties of silver-doped As2S
refraction_index=sqrt(refraction_index_squared);

%returning appropriate variable
    if vbr_type == 1 %epsilon
        result=refraction_index.^2./mu;
    elseif vbr_type == 2 %mu
        result=mu;
    elseif vbr_type == 3 %n2
        result=frequencyOKE( refraction_index, omega, CONST );
    elseif vbr_type==5 %debug refractive index
        result=refraction_index;
    end
end