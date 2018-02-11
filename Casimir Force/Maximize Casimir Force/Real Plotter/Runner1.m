	res_eps=40;
res_mu=40;

eps_1=linspace(-15,-1.5,res_eps/2);
mu_1=linspace(-15,-1.5,res_mu/2);
eps_2=linspace(1.5,15,res_eps/2);
mu_2=linspace(1.5,15,res_mu/2);
eps=cat(2,eps_1,0,eps_2);
mu=cat(2,mu_1,0,mu_2);

Frun=zeros(res_eps,res_mu);
for i=1:(res_eps+1)
    parfor j=1:(res_mu+1)
        if eps(i)==0
            result(3)=NaN;
        elseif mu(j)==0
            result(3)=NaN;
        elseif mu(j) >0 && eps(i)<0
            result(3)=NaN;
        else 
            result=CasimirForce(0.1,eps(i),mu(j));
        end
        Frun(j,i)=result(3);
    end
end

[eps_big,mu_big]=meshgrid(eps,mu);
surf(eps_big,mu_big,(real(Frun)./1.296048812447725e+05));
xlabel('$\epsilon$','Interpreter','LaTeX','FontSize',12)
ylabel('$\mu$','Interpreter','LaTeX','FontSize',12)
zlabel('$F_c/ K$','Interpreter','LaTeX','FontSize',12)