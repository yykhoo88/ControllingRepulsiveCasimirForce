x=linspace(-1e8,1e8,10000);
y=(YAG_epsilon_fixed(-x,0))-(YAGeps(-x,0));
plot(x,real(y),x,imag(y));