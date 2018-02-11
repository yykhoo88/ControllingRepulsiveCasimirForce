precisionX=25;
precisionI=25;
Xrun=linspace(0.17,0.5,precisionX);
Irun=logspace(16,19,precisionI);
Frun=zeros(precisionI,precisionX); %data for quadgk + convergence tested method
Frun2=zeros(precisionI,precisionX); %data for Trapz method

for runx=1:precisionX
    temp_X=Xrun(runx);
    parfor runi=1:precisionI
        dummy=CasimirForceITDL(0,0.8,temp_X,Irun(runi));
        Frun(runi,runx)=dummy(3);
        Frun2(runi,runx)=dummy(2);
    end
end


[Xbig,Ibig]=meshgrid(Xrun,Irun);
surf(Xbig,Ibig,real(Frun));
shading interp;
xlabel('$ a/\lambda_0 $','Interpreter','LaTeX')
ylabel('$I(t) \eta _2$','Interpreter','LaTeX')
zlabel('$F_c$ in units of $\frac{hc}{64 \pi^3 \lambda_0^4}$','Interpreter','LaTeX')
 