f = @(x,y,z,t) CasimirForceITDL(0.1,x,y,z,t);
fun = @(x) f(x(1),x(2),x(3),x(4));
x0 = [1;1;1;1];
lb = [0.001;0.001;0.001;0.001];
ub = [100;100;100;100];
%options = optimset('LargeScale','off');
options = optimset('algorithm', 'interior-point');
options = optimset(options,'Display','iter');
[x, fval, exitflag, output] = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);

%x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon,options)