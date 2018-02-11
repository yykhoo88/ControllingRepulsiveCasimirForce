precisionT=20;
precisionP=20;
Trun=linspace(0.1,100,precisionT);
Prun=linspace(0.1,100,precisionP);
Frun=zeros(precisionP,precisionT); %data for quadgk + convergence tested method
Frun2=zeros(precisionP,precisionT); %data for Trapz method
for runt=1:precisionT
    parfor runp=1:precisionP
        dummy=CasimirForceITDL(0.1,Prun(runp),Trun(runt));
        Frun(runp,runt)=dummy(3);
        Frun2(runp,runt)=dummy(2);
    end
end

[Pbig,Tbig]=meshgrid(Prun,Trun);
surf(Pbig,Tbig,Frun);
shading interp;
xlabel('$\omega_P_\epsilon$','Interpreter','LaTeX')
ylabel('$\omega_T_\epsilon$','Interpreter','LaTeX')
zlabel('$F_c/K$','Interpreter','LaTeX')
 