x=linspace(-1.5e4,1.5e4,10000);
y=YAG_epsilon( x );
plot(x,real(y),x,imag(y));