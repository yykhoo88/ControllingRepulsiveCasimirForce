function result = YAG_epsilon( omega_p )
%Constants
CONST.hbar = 1.054571726*(10^-34);
CONST.e = 1.602176487*(10^-19);
CONST.me = 9.10938188*(10^-31);
CONST.c=299792458;
CONST.a=0.52917720859*(10^-10);
CONST.epsilon_0=8.85418782e-12;

%Global Variables
VAR.omega_31=0; %no idea where to get
VAR.omega_21=0; %no idea where to get

VAR.omega_p=omega_p; %probe frequency = Casimir Frequencies
VAR.omega_c=VAR.omega_31; %Let resonant point
VAR.Omega_p=60;
VAR.Omega_c=730;
VAR.Gamma_21=239.1;
VAR.Gamma_31=190.6;
VAR.Gamma_32=2391;
VAR.N=0.52;
VAR.gamma_dph_21=20 .* VAR.Gamma_21;
VAR.gamma_dph_31=20 .* VAR.Gamma_21;
VAR.gamma_dph_32=20 .* VAR.Gamma_21;
VAR.mu_21 = 3.106e-32;

%EQN 1
VAR.delta_p=VAR.omega_p - VAR.omega_21;
VAR.delta_c=VAR.omega_c - VAR.omega_31;

%Calculate EQN 3
VAR.gamma_13 = calc_gamma_13(CONST,VAR);
VAR.gamma_23 = calc_gamma_23(CONST,VAR);
VAR.gamma_12 = calc_gamma_12(CONST,VAR);

result=chi_kernel(CONST,VAR);

end

%====Computing EQN 7======
function result = chi_kernel(CONST,VAR)
	result = ((VAR.N .* (6.02214129e23) ./10 .* 2000).* (VAR.mu_21 .^2) .* calc_rho_12(CONST,VAR)) ./ (CONST.epsilon_0 .* VAR.Omega_p .* CONST.hbar);
end

function result = calc_n (CONST,VAR)
	chi_val=chi_kernel(CONST,VAR);
	result = sqrt(1 + (4 .* pi .* (chi_val)));
end

function result = calc_epsilon(CONST,VAR)
	result = (calc_n (CONST,VAR)).^2;
end

%====Computing EQN 6======
function result = calc_A(CONST,VAR)
	result = (2 .* (abs(VAR.Omega_c)).^2 .* VAR.gamma_13) ./ (VAR.gamma_13.^2 + VAR.delta_c.^2);
end

function result = calc_rho_22(rho_11,CONST,VAR)
	var_A=calc_A(CONST,VAR);
	result=(VAR.Gamma_32 .* var_A) ./ (VAR.Gamma_21 .* (VAR.Gamma_31 + VAR.Gamma_32 + var_A)) .* rho_11;
end

function result = calc_rho_33(rho_11,CONST,VAR)
	var_A=calc_A(CONST,VAR);
	result=(var_A) ./ (VAR.Gamma_31 + VAR.Gamma_32 + var_A) .* rho_11;
end

function result = rho_wrapper(rho_11,CONST,VAR)
	result = rho_11 + calc_rho_22(rho_11,CONST,VAR) + calc_rho_33(rho_11,CONST,VAR) -1;
end

function result = calc_rho_11(CONST,VAR)
	options=optimset('Display','iter','TolX',1e-10);
	result=fzero(@(rho_11) rho_wrapper(rho_11,CONST,VAR),[-100 100],options);
end

function result = calc_rho_12(CONST,VAR)
	rho_11=calc_rho_11(CONST,VAR);
	rho_22=calc_rho_22(rho_11,CONST,VAR);
	rho_33=calc_rho_33(rho_11,CONST,VAR);
	temp_upper=(1i .* VAR.Omega_p .* (rho_22 - rho_11)) - ((1i .* (abs(VAR.Omega_c)).^2 .* VAR.Omega_p .* (rho_11 - rho_33))./((VAR.gamma_23 + 1i .* (VAR.delta_p - VAR.delta_c)) .* (1i.* VAR.delta_c - VAR.gamma_13)));
	temp_lower=VAR.gamma_12 + (1i .* VAR.delta_p) + ((abs(VAR.Omega_c)).^2 ./ (VAR.gamma_23 + 1i .* (VAR.delta_p - VAR.delta_c)));
	result=temp_upper ./ temp_lower;
end



%====Computing EQN 3======
function result = calc_gamma_13(CONST,VAR)
	result = (1 ./2).* (VAR.Gamma_31 + VAR.Gamma_32 + VAR.gamma_dph_31);
end

function result = calc_gamma_23(CONST,VAR)
	result = (1 ./2).* (VAR.Gamma_31 + VAR.Gamma_32 + VAR.Gamma_21 + VAR.gamma_dph_32);
end

function result = calc_gamma_12(CONST,VAR)
	result = (1 ./2).* (VAR.Gamma_21 + VAR.gamma_dph_21);
end