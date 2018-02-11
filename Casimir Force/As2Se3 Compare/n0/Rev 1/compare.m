CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-6;
CONST.e=1.602176565e-19;

%resonant frequency 2.5e15
x=linspace(0.1e15,2e16,20000);
z1=As2Se3Var(x,5,CONST);
z2=As2Se3Const(x,0,5);

plot(x,real(z1),x,imag(z1),x,z2);
xlabel('$\omega$','Interpreter','LaTeX','FontSize',10)
ylabel('$n_2$','Interpreter','LaTeX','FontSize',10)
set(gca,'FontSize',10)
set(gcf,'OuterPosition',[1 1 450 400]);
set(gca,'OuterPosition',[0 0.05 1 0.95]);
