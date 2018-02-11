x=logspace(10,18,10000);
epsilon_A=IRMod(x,0,1);
mu_A=IRMod(x,0,2);

[mu_A_angle, mu_A_radius] = cart2pol( real(mu_A), imag(mu_A) );
[epsilon_A_angle, epsilon_A_radius] = cart2pol( real(epsilon_A), imag(epsilon_A) );
eta_A = sqrt(mu_A_radius.*epsilon_A_radius) .* exp(1i./2.*(epsilon_A_angle+mu_A_angle));

semilogx(x,real(eta_A),x,imag(eta_A))
