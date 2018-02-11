f = @(x,y) CasimirForceITDL(0.1,x,y);
fun = @(x) f(x(1),x(2));
x0 = [1; 1];
options = optimset('LargeScale','off');
options = optimset(options,'Display','iter');
[x, fval, exitflag, output] = fminunc(fun,x0,options);