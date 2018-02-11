f = @(x,y) CasimirForceITDL(0.1,x,y);
fun = @(x) f(x(1),x(2));
x0 = [1.14846195472635e-06;1.382203936022309];
options = optimset('LargeScale','on');
options = optimset(options,'Display','iter');
[x, fval, exitflag, output] = fminsearch(fun,x0,options);