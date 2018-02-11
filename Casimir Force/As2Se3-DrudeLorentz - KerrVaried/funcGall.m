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