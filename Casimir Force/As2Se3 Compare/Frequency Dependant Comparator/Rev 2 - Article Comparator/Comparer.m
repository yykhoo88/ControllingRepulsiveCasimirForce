
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

XiMin=1e12;
XiMax=1e16; %6e15
positionX=0.2;
I=0;
KerrVaried=CasimirForceITDL(0,0,positionX,0,XiMin,XiMax);
KerrVaried1=CasimirForceITDL(0,0,positionX,1e18,XiMin,XiMax);
KerrVaried2=CasimirForceITDL(0,0,positionX,1e19,XiMin,XiMax);
%KerrConst=CasimirForceITDLold(0,0,positionX,I,XiMin,XiMax);

semilogx(KerrVaried.x,KerrVaried.y,KerrVaried1.x,KerrVaried1.y,KerrVaried2.x,KerrVaried2.y);
xlabel('$\xi$','Interpreter','LaTeX','FontSize',12)
ylabel('$\frac{dF_c}{d\xi} / K$','Interpreter','LaTeX','FontSize',12)
set(gca,'FontSize',12)
set(gcf,'OuterPosition',[1 1 450 400]);
set(gca,'OuterPosition',[0 0.05 1 0.95]);
