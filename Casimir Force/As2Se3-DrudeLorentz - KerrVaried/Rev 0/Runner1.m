precisionX=7;
precisionI=60;
Xrun=[0.17 0.2 0.25 0.3 0.35 0.4 0.45 0.5];
Irun=logspace(5e17,10e18,precisionI);
Frun=zeros(precisionI,precisionX); %data for quadgk + convergence tested method
Frun2=zeros(precisionI,precisionX); %data for Trapz method
for runx=1:precisionX
    Xtemp=Xrun(runx);
    parfor runi=1:precisionI
        dummy=CasimirForceITDL(0,0,Xtemp,Irun(runi));
        Frun(runi,runx)=dummy(3);
        Frun2(runi,runx)=dummy(2);
    end
end

plot(Irun,Frun);
xlabel('$I(t)/\eta _2$','Interpreter','LaTeX','FontSize',10)
ylabel('$F_c \times K$ ($Nm^{-2}$)','Interpreter','LaTeX','FontSize',10)
set(gca,'FontSize',10)
set(gcf,'OuterPosition',[1 1 450 400]);
set(gca,'OuterPosition',[0 0.05 1 0.95]);
