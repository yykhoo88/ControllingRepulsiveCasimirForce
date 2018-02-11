precisionX=5;
precisionI=10;
Xrun=[0.2 0.25 0.3 0.35 0.4];
Irun=linspace(0.001e18,1e18,precisionI);
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
xlabel('$I$','Interpreter','LaTeX','FontSize',10)
ylabel('$F_c/K$','Interpreter','LaTeX','FontSize',10)
set(gca,'FontSize',10)
set(gcf,'OuterPosition',[1 1 450 400]);
set(gca,'OuterPosition',[0 0.05 1 0.95]);
