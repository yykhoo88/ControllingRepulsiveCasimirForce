function result = YAGsus( omega_p )
%Constants
CONST.hbar = 1.054571726*(10^-34);
CONST.e = 1.602176487*(10^-19);
CONST.me = 9.10938188*(10^-31);
CONST.c=299792458;
CONST.a=0.52917720859*(10^-10);
CONST.epsilon_0=8.85418782e-12;

%new Global Variables
VAR.mu_12=2.47e-32;
VAR.mu_13=1.11e-32;
VAR.mu_23=1.19e-32;
VAR.tau_2=2.0e-6;
VAR.tau_3=0.5e-6;
VAR.omega_31=0;
VAR.omega_21=0; %change this?
VAR.omega_p=NaN; %probe frequency = Casimir Frequencies
VAR.omega_c=VAR.omega_31; %Assuming resonant point

%computing Gamma
VAR.Gamma_21=200; %THIS IS REQUIRED!!!! WHERE TO FIND!!!!
VAR.Gamma_31=0;
VAR.Gamma_32=NaN; %we don't know this either

%computing other gamma(s)
VAR.gamma_2=1./VAR.tau_2 - VAR.Gamma_31;
VAR.Gamma_32_gamma_3=1./VAR.tau_3;
VAR.gamma_21=(1./2).*(VAR.Gamma_21 + VAR.gamma_2);
VAR.gamma_31=(1./2).*(VAR.Gamma_31 + VAR.Gamma_32_gamma_3);
VAR.gamma_32=(1./2).*(VAR.Gamma_31 + VAR.Gamma_32_gamma_3 + VAR.Gamma_21 + VAR.gamma_2);
VAR.N=0.33;

%EQN 1
VAR.delta_p= NaN;%VAR.omega_21 - omega_p;
VAR.delta_c= VAR.omega_31 - VAR.omega_c;

%computing energies
VAR.Ep=(1./10).*(1./VAR.mu_12).*(1./VAR.tau_2).*(2.*CONST.hbar);
VAR.Ec=(20).*(1./VAR.mu_23).*(1./VAR.tau_2).*(2.*CONST.hbar);

%computing Rabi frequency
VAR.Omega_p=VAR.mu_12.*VAR.Ep./(2.*CONST.hbar);
VAR.Omega_c=VAR.mu_23.*VAR.Ec./(2.*CONST.hbar);

result=chi(CONST,VAR,omega_p);

end

function result=chi(CONST,VAR,omega_p)
	result=(2 .* VAR.N .* VAR.mu_12 .* rho_21_calc_array(CONST,VAR,omega_p)) ./ (CONST.epsilon_0 .* VAR.Ep);
end

function result=rho_21_calc_array(CONST,VAR,omega_vec)
	result = arrayfun(@(omega_p) rho_21_calc(CONST,VAR,omega_p),omega_vec);
end

function result = rho_21_calc(CONST,VAR,omega_p)
	ans=GenMatrix(CONST,VAR,omega_p)\(-GenVec(CONST,VAR,omega_p));
	result=ans(4);
end

function result = GenMatrix(CONST,VAR,omega_p)
	mat=zeros(8);
	
	%rho_11
	mat(1,1)=-VAR.Gamma_31;
	mat(1,2)=-1i.*VAR.Omega_p;
	mat(1,4)=1i.*VAR.Omega_p;
	mat(1,5)=VAR.Gamma_21 + VAR.gamma_2 - VAR.Gamma_31;
	
	%rho_12
	mat(2,1)=-1i.*VAR.Omega_p;
	mat(2,2)=-(VAR.gamma_21 - 1i .* (VAR.omega_21 - omega_p));
	mat(2,3)=-1i.*VAR.Omega_c;
	mat(2,5)=1i.*VAR.Omega_p;
	
	%rho_13
	mat(3,2)=-1i.*VAR.Omega_c;
	mat(3,3)=-(VAR.gamma_32 - 1i.*((VAR.omega_21 - omega_p) + VAR.delta_c));
	mat(3,6)=1i.*VAR.Omega_p;
	
	%rho_21
	mat(4,1)=1i.*VAR.Omega_p;
	mat(4,4)=-(VAR.gamma_21 + 1i.*(VAR.omega_21 - omega_p));
	mat(4,5)=-1i.*VAR.Omega_p;
	mat(4,7)=1i.*VAR.Omega_c;
	
	%rho_22
	mat(5,1)=-(VAR.Gamma_32_gamma_3);
	mat(5,2)=1i.*VAR.Omega_p;
	mat(5,4)=-1i.*VAR.Omega_p;
	mat(5,5)=-(VAR.Gamma_21 + VAR.gamma_2)-(VAR.Gamma_32_gamma_3);
	mat(5,6)=-1i.*VAR.Omega_c;
	mat(5,8)=1i.*VAR.Omega_c;
	
	%rho_23
	mat(6,1)=-1i.*VAR.Omega_c;
	mat(6,3)=1i.*VAR.Omega_p;
	mat(6,5)=-2i.*VAR.Omega_c;
	mat(6,6)=-(VAR.gamma_32 - 1i.*VAR.delta_c);
	
	%rho_31
	mat(7,4)=1i.*VAR.Omega_c;
	mat(7,7)=-(VAR.gamma_32 + 1i.*(VAR.delta_c + (VAR.omega_21 - omega_p)));
	mat(7,8)=-1i.*VAR.Omega_p;
	
	%rho_32
	mat(8,1)=1i.*VAR.Omega_c;
	mat(8,5)=2i.*VAR.Omega_c;
	mat(8,7)=-1i.*VAR.Omega_p;
	mat(8,8)=-(VAR.gamma_32 + 1i.*VAR.delta_c);
	
	result=mat;
end

function result=GenVec(CONST,VAR,omega_p)
	mat=zeros(8,1);
	mat(1,1)=VAR.Gamma_31;
	mat(5,1)=VAR.Gamma_32_gamma_3;
	mat(6,1)=1i.*VAR.Omega_c;
	mat(8,1)=-1i.*VAR.Omega_c;
	
	result=mat;
end
