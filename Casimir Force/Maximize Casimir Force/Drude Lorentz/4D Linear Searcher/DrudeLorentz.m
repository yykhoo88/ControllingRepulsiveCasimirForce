
function result=DrudeLorentz(omega,omega_0,vbr_type,CONST)

%Initial variable defining
omega_P_e=CONST.omega_p_e.*omega_0; %changing this gives a sharper asymptote
omega_T_e=CONST.omega_t_e.*omega_0; %changing this redefine the position
gamma_e=1e-2.*omega_T_e;

omega_P_m=CONST.omega_p_m.*omega_0;
omega_T_m=CONST.omega_t_m.*omega_0;
gamma_m=1e-2.*omega_T_m;

%returning appropriate variable
    if vbr_type == 1
        if omega_P_e<0
            result=NaN;
        elseif omega_T_e<0
            result=NaN;
        else
            result=1+omega_P_e.^2./(omega_T_e.^2 - omega.^2 - 1i.*gamma_e.*omega);
        end
    elseif vbr_type == 2
        if omega_P_m<0
            result=NaN;
        elseif omega_T_m<0
            result=NaN;
        else
            result=1+omega_P_m.^2./(omega_T_m.^2 - omega.^2 - 1i.*gamma_m.*omega);
        end
    end
end
