function result=Gold(omega,omega_0,vbr_type)

%initializing As2S3 glass
mu=1+(-3.36e-10); %susceptibility by Z. CIMPL et al phys. stat. sol. 41, 535 (1970)
refraction_index=2.4; %T.I. Kosa et al. / Nonlinear optical properties of silver-doped As2S z
kerr_const=1.4e-17;



%returning appropriate variable
    if vbr_type == 1
        result=refraction_index.^2./mu;
    elseif vbr_type == 2
        result=mu;
    elseif vbr_type == 3
        result=kerr_const;
    end
end