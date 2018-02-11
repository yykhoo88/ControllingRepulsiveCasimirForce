function result=As2Se3(omega,omega_0,vbr_type)

%initializing As2S3 glass
mu=1; %any glass should have this value
refraction_index=2.7; %slusher et al
kerr_const=1.1e-13 .* ((10.^(-2)).^2); %slusher et al



%returning appropriate variable
    if vbr_type == 1
        result=refraction_index.^2./mu;
    elseif vbr_type == 2
        result=mu;
    elseif vbr_type == 3
        result=kerr_const;
    end
end