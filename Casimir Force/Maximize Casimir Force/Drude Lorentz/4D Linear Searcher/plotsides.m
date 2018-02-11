function result = plotsides( plottype )
x_optim=[0.00400491547378593;
67.1744151363065;
99.9999999910852;
0.00100000012411902];

%other variables
precisionT=10;
precisionP=10;
Frun=zeros(precisionP,precisionT);
Frun2=zeros(precisionP,precisionT);

if plottype==1 %testing E
    Prun=linspace(x_optim(1)-x_optim(1)*2,x_optim(1)+x_optim(1)*2,precisionP);
    Trun=linspace(x_optim(2)-x_optim(2)*2,x_optim(2)+x_optim(2)*2,precisionT);
    for runt=1:precisionT
        parfor runp=1:precisionP
            Frun(runt,runp)=CasimirForceITDL(0.1,Prun(runp),Trun(runt),x_optim(3),x_optim(4));
        end
    end
elseif plottype==2 %testing M
    Prun=linspace(x_optim(3)-x_optim(3)*2,x_optim(3)+x_optim(3)*2,precisionP);
    Trun=linspace(x_optim(4)-x_optim(4)*2,x_optim(4)+x_optim(4)*2,precisionT);
    for runt=1:precisionT
        parfor runp=1:precisionP
            Frun(runt,runp)=CasimirForceITDL(0.1,x_optim(1),x_optim(2),Prun(runp),Trun(runt));
        end
    end
end

[Pbig,Tbig]=meshgrid(Prun,Trun);
h=surf(Pbig,Tbig,Frun./1.298268659815012e+05);
%set(get(h,'Parent'),'XScale','log');
%set(get(h,'Parent'),'YScale','log');
%shading interp;
xlabel('$ \omega_{P_{\epsilon}}$','Interpreter','LaTeX')
ylabel('$\omega_{T_{\epsilon}}$','Interpreter','LaTeX')
zlabel('$F_c/F_0$','Interpreter','LaTeX')
 

result=0;
end

