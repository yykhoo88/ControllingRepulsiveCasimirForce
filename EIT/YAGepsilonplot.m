x=linspace(-1e8,1e8,10000);
y=YAG_epsilon_fixed(-x,0);
plot(x,real(y),x,imag(y));
%xlim([-7e6 7e6]);
%ylim([-2 2])


%{

x=linspace(-7e6,7e6,10000);
for i=1:10000
	y(i)=YAG_epsilon( -x(i).*2.*pi );
	%y(i)=YAG_epsilon_fixed(-x(i).*2.*pi,0);
end
plot(x,real(y).*8e25./6);
xlim([-7e6 7e6]);
ylim([-2 2])

%}