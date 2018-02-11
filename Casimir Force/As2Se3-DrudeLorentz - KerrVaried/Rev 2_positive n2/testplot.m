CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-6;
CONST.e=1.602176565e-19;

x=linspace(2e15,3e15,1000);
%y=As2Se3(x,3,CONST);
y=testass(x,CONST);
plot(x,real(y),x,imag(y));
