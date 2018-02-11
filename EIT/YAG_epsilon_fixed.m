function result=YAG_epsilon_fixed(omega_p,omega_21)
	susceptibility=YAG_susceptibility( -(omega_21 - omega_p) ).*8e25./6 .*5;
	result=1+susceptibility;
	%result=result_temp+1;
end