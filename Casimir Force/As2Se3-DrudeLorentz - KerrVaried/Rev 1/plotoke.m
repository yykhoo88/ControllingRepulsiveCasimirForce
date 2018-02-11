%plotOKE


function result=plotoke()
	CONST.h_bar=1.054571596*(10^(-34));
	CONST.c=299792458;
	CONST.epsilon_0=8.854187817*(10^(-12));
	CONST.mu_0=1.256637061*(10^(-6));
	CONST.lambda0=1e-6;
	CONST.e=1.602176565e-19;



	x=linspace(0.1,0.8,100000);

	y=funcG(x,1,0,1)+funcG(x,1,0,2)+funcG(x,1,0,3)+funcG(x,1,0,4)-funcG(x,1,0,5);
	z=y./y(1);
	plot(x,real(z),x,imag(z));
end

function result = funcG( x_omega,omega_bandgap,gamma,type)
	%x=(x_omega - 1i.*gamma)./omega_bandgap;
	x=x_omega./omega_bandgap;
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