set(0,'defaulttextinterpreter','latex')
figure
set(gcf,'PaperUnits','centimeters')
set(gcf,'renderer','painters')
figureXSize = 8.6;
figureYSize = 15;


set(gcf,'PaperSize',[figureXSize figureYSize])
set(gcf,'PaperPosition',[0 0 figureXSize figureYSize])
set(gcf,'Position',[60 50 figureXSize*50 figureYSize*50])

set(gcf,'Units','normalized')

%horizontal lengths
axesX = 1.5/figureXSize;
axesWidth = 6.1/figureXSize;
axesMarginX = 0/figureXSize; %neverused

%vertical lengths
axesY = 2/figureYSize;
axesHeight = 5/figureYSize;
axesMarginY = 2/figureYSize; 

axesX1 = axesX + 0*(axesWidth+axesMarginX);
axesX2 = axesX + 0*(axesWidth+axesMarginX);
axesY1 = axesY + 0*(axesHeight+axesMarginY);
axesY2 = axesY + 1*(axesHeight+axesMarginY);


axes_num(1,1) = axes('position',[axesX1, axesY1, axesWidth, axesHeight]);
set(gca,'box','off');
axes_num(2,1) = axes('position',[axesX2, axesY2, axesWidth, axesHeight]);
set(gca,'box','off');


axes('position',[0 0 1 1],'visible','off')
axis([0 1 0 1])

labelXOffset = 1.2/figureXSize;
labelYOffset = 1.2/figureYSize;
text(0.5,(axesY1+axesHeight) + labelYOffset - 0.03,'a)','FontSize',12,'Interpreter','none')
text(0.5, 1 - (axesY2+axesHeight) - 0.02,'b)','FontSize',12,'Interpreter','none') %,'FontWeight','bold'

subplot(axes_num(1,1)), plot(x1{5},y1{5},'-',x1{3},y1{3},'--',x1{1},y1{1},'-.')
xlabel('$I$ ($W/m^2$)','Interpreter','LaTeX','FontSize',12)
ylabel('$F_c/ K$','Interpreter','LaTeX','FontSize',12)
set(gca,'FontSize',10)
%set(0,'defaulttextinterpreter','tex')
%legend('I = 0 W/m^2')
yyl=legend('$a=0.20\lambda_0$','$a=0.30\lambda_0$','$a=0.40\lambda_0$')
%set(yyl,'FontSize',8);
%set(gca,'YLim',[-1500 1900])%,'YLim',[0 100])
set(0,'defaulttextinterpreter','latex')

subplot(axes_num(2,1)), emp=surf(x2,y2,z2)
xlabel('$a/\lambda_0$','Interpreter','LaTeX','FontSize',12)
ylabel('$I$ ($W/m^2$)','Interpreter','LaTeX','FontSize',12)
zlabel('$F_c/ K$','Interpreter','LaTeX','FontSize',12)
camorbit(axes_num(2,1),0,-20)
shading interp
%rotate(emp,[0.5,1e17,24.7221],10,[0.17,4e18,-751.3361])
axis([0.1,0.5,0,4e18,-800,800])
set(axes_num(2,1),'ztick',-800:200:800)
set(gca,'FontSize',10)
%legend('I = 0 W/m^2')