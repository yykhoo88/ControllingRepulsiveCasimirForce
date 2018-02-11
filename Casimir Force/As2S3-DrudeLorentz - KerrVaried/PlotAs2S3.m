CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-6;
CONST.e=1.602176565e-19;

%resonant frequency 2.5e15
x=logspace(1,20,200000);
z=As2S3(x,3,CONST);

semilogx(x,real(z),x,imag(z));