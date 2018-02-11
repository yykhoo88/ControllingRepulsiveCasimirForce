function result=YAGeps(omega_p,omega_21)
	susceptibility=YAGsus( -(omega_21 - omega_p) ).*8e25./6 .*5;
	result=1+susceptibility;
	%result=result_temp+1;
end