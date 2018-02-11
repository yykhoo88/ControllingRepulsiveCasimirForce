x=logspace(10,18,10000);
y=IRMod(x,0,2);
semilogx(x,real(y),x,imag(y))
