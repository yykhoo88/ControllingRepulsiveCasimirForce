
function result=IRMod(omega,omega_0,vbr_type)
CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;

%Initial variable defining
%take GaN from SC Lim, for parallel to growth direction
twopic=2 .* pi .* CONST.c
eps_inf=5.31;
omega_LO=734 .* twopic;
omega_TO=532 .* twopic;
gamma_LO=0.01 .* omega_LO;
gamma_TO=0.01 .* omega_TO;

%returning appropriate variable
    if vbr_type == 1
        result=eps_inf.*((omega_LO.^2 - omega.^2 - 1i.*omega.*gamma_LO)./(omega_TO.^2 - omega.^2 - 1i.*omega.*gamma_TO));
    elseif vbr_type == 2
        result=omega./omega;
    end
end
