function result=As2Se3Var(omega,vbr_type,CONST)

%omega_0 is a stupid dummy variable.

%initializing As2S3 glass
mu=1+(-3.36e-10); %susceptibility by Z. CIMPL et al phys. stat. sol. 41, 535 (1970)

%refraction index
%variables
var_E_d=26 .* CONST.e; %normally, Slusher et al
var_E_s=4.1 .* CONST.e; %As2Se3 value, Slusher et al
var_gamma = 0.01 .* var_E_s ./ CONST.h_bar;

%computing refractive index
refraction_index_squared = (var_E_d .* var_E_s ./ (var_E_s.^2 - (CONST.h_bar .* omega).^2 - (1i .* CONST.h_bar.^2 .* omega .* var_gamma) )) + 1; %Slusher et al (Wemple equation)
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

function [ var_eta2 ] = frequencyOKE( var_eta0, omega, CONST )
%Frequency dependant n2: accepts n0 and omega as input, returns n2

%Declaring Variables
var_d=0.243; %As2Se3 Slusher et al
var_E_s=4.1 .* CONST.e; %As2Se3 Slusher et al
var_E_g=var_E_s ./ 2.5; %the usual approximation of var_E_s ~ 2.5 var_E_g (Lenz)
var_omega_bandgap=var_E_g./CONST.h_bar;
var_gamma=0.01.*var_omega_bandgap;
var_eta0=real(var_eta0);

var_eta0_const=2.7; %Slusher et al

%computing the eta2
var_eta2=1.7e-18 .* (var_eta0_const.^2 + 2).^3 .* (var_eta0_const.^2 - 1) .* (var_d ./ var_eta0_const ./ (var_E_s ./ CONST.e)) .* (var_d ./ var_eta0_const ./ (var_E_s ./ CONST.e)) .* funcGall(omega,var_omega_bandgap,var_gamma);
end

function result=funcGall( x_omega,omega_bandgap,gamma)
    x_cutoff=0.05.*omega_bandgap;
	y=funcG(x_omega,omega_bandgap,gamma,1)+funcG(x_omega,omega_bandgap,gamma,2)+funcG(x_omega,omega_bandgap,gamma,3)+funcG(x_omega,omega_bandgap,gamma,4)-funcG(x_omega,omega_bandgap,gamma,5);
    y_cutoff=funcG(x_cutoff,omega_bandgap,gamma,1)+funcG(x_cutoff,omega_bandgap,gamma,2)+funcG(x_cutoff,omega_bandgap,gamma,3)+funcG(x_cutoff,omega_bandgap,gamma,4)-funcG(x_cutoff,omega_bandgap,gamma,5);
    y_normalized=y./real(y_cutoff);
    test1 = (x_omega < x_cutoff).*1;
    test2 = (x_omega >= x_cutoff).*y_normalized;
    result = test1 + test2;
end

function result = funcG( x_omega,omega_bandgap,gamma,type)
	x=(x_omega - 1i.*gamma)./omega_bandgap;
    if (type==1) %two photon absorption
        result= (1./(2.*x).^6) .* (-3./8.*x.^2.*(1-x).^(-1/2) + 3.*x.*(1-x).^(1/2) - 2.*(1-x).^(3/2) + 2.*heavisideyy(1-2.*x).*(1-2.*x).^(3/2));
    elseif (type==2) %Raman
        result= (1./(2.*x).^6) .* (-3./8.*x.^2.*(1+x).^(-1/2) - 3.*x.*(1+x).^(1/2) - 2.*(1+x).^(3/2) + 2.*(1+2.*x).^(3/2));
    elseif (type==3) %Linear Stark
        result= (1./(2.*x).^6) .* (2 - (1-x).^(3/2) - (1+x).^(3/2));
    elseif (type==4) %Quadratic Stark
        result=(1./ 2.^10 ./ x.^5) .* ((1-x).^(-1/2) - (1+x).^(-1/2) - (x./2.*(1-x).^(-3/2)) - (x./2.*(1+x).^(-3/2)) );
    elseif (type==5) %Divergent term
        result=(1./(2.*x).^6) .* (-2 - (35.*x.^2./8) + (x./8.*(3.*x-1).*(1-x).^(-1/2)) - (3.*x.*(1-x).^(1/2)) + ((1-x).^(3/2)) + (x./8.*(3.*x+1).*(1+x).^(-1/2)) + (3.*x.*(1+x).^(1/2)) + ((1+x).^(3/2)) );
    elseif(type==99) %for debugging
        result =(1./(2.*x).^6) .* (-3./8.*x.^2.*(1-x).^(-1/2) + 3.*x.*(1-x).^(1/2) - 2.*(1-x).^(3/2) + 2.*heavisideyy(1-2.*x).*(1-2.*x).^(3/2));
    else
        error('Error on funcG: No idea which type is used');
    end
end

function Y = heavisideyy (X)
    Y = zeros(size(X));
    Y(X > 0) = 1;
    Y(X == 0) = .5;
end