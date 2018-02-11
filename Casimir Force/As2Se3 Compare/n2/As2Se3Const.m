function result=As2Se3Const(omega,omega_0,vbr_type)

%initializing As2S3 glass
mu=1; %any glass should have this value
refraction_index=2.7; %slusher et al
kerr_const=1.1e-13 .* ((10.^(-2)).^2); %slusher et al
kerr_const=4.131083889535023e-18; %change to low frequency limit.



%returning appropriate variable
    if vbr_type == 1
        result=omega./omega.*refraction_index.^2./mu;
    elseif vbr_type == 2
        result=omega./omega.*mu;
    elseif vbr_type == 3
        result=omega./omega.*kerr_const;
    end
end