function [ result ] = Comparer( positionX,I )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

XiMin=0.000001;
XiMax=1e16; %6e15

KerrVaried=CasimirForceITDL(0,0,positionX,I,XiMin,XiMax);
KerrConst=CasimirForceITDLold(0,0,positionX,I,XiMin,XiMax);

plot(KerrConst.x,KerrConst.y,KerrVaried.x,KerrVaried.y);
xlabel('$\xi$','Interpreter','LaTeX','FontSize',12)
ylabel('$\frac{dF_c}{d\xi} / K$','Interpreter','LaTeX','FontSize',12)
set(gca,'FontSize',12)
set(gcf,'OuterPosition',[1 1 450 400]);
set(gca,'OuterPosition',[0 0.05 1 0.95]);

result.KerrVaried=KerrVaried;
result.KerrConst=KerrConst;
end

