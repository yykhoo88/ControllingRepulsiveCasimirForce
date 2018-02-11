%{
precisionX=3;
%precisionI=60;
Xrun=[0.1,0.5,1];
%Irun=linspace(0,100,precisionI);
Frun=zeros(1,precisionX); %data for quadgk + convergence tested method
%Frun2=zeros(precisionI,precisionX); %data for Trapz method
for runx=1:precisionX
        dummy{runx}=CasimirForceIT(1,0.75,Xrun(runx),0);
end

%semilogx(dummy{1}{1},dummy{1}{2},dummy{2}{1},dummy{2}{2}.*10^10,dummy{3}{1},dummy{3}{2});
plotyy(dummy{1}{1},dummy{1}{2},dummy{3}{1},dummy{3}{2},'semilogx','semilogx')
set(gca,'XLim',[1e13 1e17]);
%}
KerrVaried=CasimirForceIT(0,0.75,0.25,0);
KerrVaried2=CasimirForceIT(0,0.75,1,0);
plotyy(KerrVaried.x,KerrVaried.y,KerrVaried2.x,KerrVaried2.y,'semilogx','semilogx');