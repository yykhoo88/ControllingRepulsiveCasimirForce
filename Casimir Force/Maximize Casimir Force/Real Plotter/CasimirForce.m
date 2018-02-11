%Program: Casimir Effect for parallel plate under influence of external
%laser with AC Kerr Effect.
%
%Programmed by: YY Khoo
%Supervised by: Dr. Raymond Ooi.
%
%Revision History
%v1.0 
%- Script will solve integration by 1-quad method and 2-trapz
%- Script run with perfect reflector (Classical casimir force)
%- Ideal answer by trapz method is found using f(1e-9,0.001,1e17,5e7,1500).
%- Answer: 
%  quad:0.006782516683629, trapz: 0.001300013647088,
%  maple:0.0013001255005567817282 (0.0086% diff)
%
%v1.0.1
%- Added speed fix for trapz (LTC)
%
%v1.1
%- f(1e-9,0.001,5e15,5e6,1500,1e20) gives perfect reflector
%  F=-0.001132583554546, (-0.8712F_0). Theory gives F=-0.875F_0
%  (0.436% diff)
%
%v1.2
%- Attempt to change program to fit Zubairy paper
%- Replaced constants to fit Zubairy's paper.
%- Added variable lambda0 (any number should fit properly.
%-                xrun (running number to plot graph).
%
%v1.3
%- Attempt to add plate's angular frequency.
%
%v1.4
%- Added search routine for XiMax,KMax
%
%v1.5
%- Finalised edition. Search routine can be improved but given in for
%better plans.
%- Output is independant of lambda0. Hard coding it to 1e-6.
%
%v1.6
%- Fixed search routine with LogSearch.
%- Added warning code: in case quadgk differs from trapz a lot. Trapz is
%not reliable compared to quadgk.
%
%v1.7
%- Fixed for index of refraction computation
%- Fixed infinite loop while searching for right position to intergrate.
%
%v1.8
%- Doing convergence test - program runtime is about 10 seconds.
%
%v1.9
%- Edit index of refraction calculation to include metamaterial.

function result = CasimirForce(PositionX,var_eps,var_mu)

CONST.h_bar=1.054571596*(10^(-34));
CONST.c=299792458;
CONST.epsilon_0=8.854187817*(10^(-12));
CONST.mu_0=1.256637061*(10^(-6));
CONST.lambda0=1e-7;
CONST.var_eps=var_eps;
CONST.var_mu=var_mu;
CONST.e=1.602176565e-19;
t=0;

%computational variables (calibrated with parallel conducting plate)
gridsize=100;
gridsizefine=2000;
a=PositionX*CONST.lambda0;
XiMin=1e-9;
XiMax=1e125;
Kmin=0.00001;
Kmax=1e125;
GridSearchPrecision=0.002;
ConvergeTestPrecision=0.01;

%Doing LogSearch: Search for the best grid for integration.
temp_research=1;
temp_searchdone=0;
while temp_research==1
    temp_research=0;
    temp_searchdone=temp_searchdone+1;
    if temp_searchdone > 5000
        display ('Warning: Search Failed. Using 10x old range. Inaccuracy might occur');
        XiMax=XiMax*10;
        Kmax=Kmax*10;
        break;
    end
    temp_searchrange=lograngefinder(XiMin,XiMax,Kmin,Kmax,GridSearchPrecision,gridsize,a,t,CONST);
    if temp_searchrange(1) < gridsize*0.95
        XiMax=temp_searchrange(2);
        temp_research=1;
    end
    if temp_searchrange(3) < gridsize*0.95
        Kmax=temp_searchrange(4);
        temp_research=1;
    end
    if temp_searchrange(1) >= gridsize
        XiMax=temp_searchrange(2)+temp_searchrange(5);
        temp_research=1;
    end
    if temp_searchrange(3) >= gridsize
        Kmax=temp_searchrange(4)+temp_searchrange(6);
        temp_research=1;
    end
    
end

%Doing LinSearch: Search for the best grid for integration.
temp_research=1;
temp_searchdone=0;
while temp_research==1
    temp_research=0;
    temp_searchdone=temp_searchdone+1;
    if temp_searchdone > 5000
        display ('Warning: Search Failed. Using 10x old range. Inaccuracy might occur');
        XiMax=XiMax*10;
        Kmax=Kmax*10;
        break;
    end
    temp_searchrange=linrangefinder(XiMin,XiMax,Kmin,Kmax,GridSearchPrecision,gridsize,a,t,CONST);
    if temp_searchrange(1) < gridsize*0.95
        XiMax=temp_searchrange(2);
        temp_research=1;
    end
    if temp_searchrange(3) < gridsize*0.95
        Kmax=temp_searchrange(4);
        temp_research=1;
    end
    if temp_searchrange(1) >= gridsize
        XiMax=temp_searchrange(2)+(XiMax-XiMin)/gridsize*2;
        temp_research=1;
    end
    if temp_searchrange(3) >= gridsize
        Kmax=temp_searchrange(4)+(XiMax-XiMin)/gridsize*2;
        temp_research=1;
    end
    
end

%dlbquad method
%result(1) = dblquad(@(xi,k) integration_kernel(xi,k,a,t,CONST),XiMin,XiMax,Kmin,Kmax,1e-20);

%quadgk include convergence test
Convergence=0;
temp_XiMax=XiMax;
temp_Kmax=Kmax;
temp_convergecount=0;
temp_CurrentValue=0;
while Convergence==0
    temp_PreviousValue=temp_CurrentValue;
    myquad = @(fun,a,b,tol,trace,varargin)quadgk(@(x)fun(x,varargin{:}),a,b,'AbsTol',tol);
    temp_CurrentValue=dblquad(@(xi,k) integration_kernel(xi,k,a,0,CONST),0,temp_XiMax,0,temp_Kmax,1e-6,myquad);
        if (abs(abs(temp_CurrentValue)-abs(temp_PreviousValue))/abs(temp_PreviousValue)) < ConvergeTestPrecision && temp_convergecount ~= 0
            Convergence=1;
        else
            temp_XiMax=temp_XiMax*1.2;
            temp_Kmax=temp_Kmax*1.2;
        end
    temp_convergecount=temp_convergecount+1;
    if temp_convergecount > 50
        display ('Error: Convergence not found! Integration value might be erronous!!');
        break;
    end
end
result(3) = temp_CurrentValue;


%trapz method
xi_vec=linspace(XiMin,XiMax,gridsizefine);
k_vec=linspace(Kmin,Kmax,gridsizefine);
[XI,K]=meshgrid(xi_vec,k_vec);
z=integration_kernel(XI,K,a,t,CONST);
result(2)=trapz(k_vec,trapz(xi_vec,z,2));


%plotting graph of function with limits
surf(XI,K,real(z));
shading interp; %interp, faceted, flat
xlabel('$ \xi $','Interpreter','LaTeX')
ylabel('$ k $','Interpreter','LaTeX')
zlabel('$\frac{\partial^2 F_c}{\partial \xi \partial k} $','Interpreter','LaTeX')

%UI: Showing end of script
fprintf('For eps=%e, mu= %e, CasimirF = %e\n',var_eps,var_mu,result(2));
end

%YY Function: this function will find suitable range for integration.(LOG)
function result = lograngefinder(XiMin,XiMax,Kmin,Kmax,var_maxvariance,gridsize,a,t,CONST)
xi_vec=logspace(log10(XiMin),log10(XiMax),gridsize);
k_vec=logspace(log10(Kmin),log10(Kmax),gridsize);
[XI,K]=meshgrid(xi_vec,k_vec);
z=integration_kernel(XI,K,a,t,CONST);
zabs=abs(z);
z_xi_scaled=max(zabs,[],1)./max(max(zabs));
z_k_scaled=max(zabs,[],2)./max(max(zabs));

result(1:4)=0;
for tempvar_i=1:gridsize
    if abs(z_xi_scaled(gridsize+1-tempvar_i)) > var_maxvariance && result(2)==0
        result(1)=gridsize+2-tempvar_i;
        if result(1)==gridsize+1
            result(2)=xi_vec(gridsize+1-tempvar_i);
        else
            result(2)=xi_vec(gridsize+2-tempvar_i);
        end
    end
    
    if abs(z_k_scaled(gridsize+1-tempvar_i)) > var_maxvariance && result(4)==0
        result(3)=gridsize+2-tempvar_i;
        if result(3) == gridsize+1
            result(4)=k_vec(gridsize+1-tempvar_i);
        else
            result(4)=k_vec(gridsize+2-tempvar_i);
        end
    end
    
    if result(2)~=0 && result(4)~=0
        break;
    end
end
result(5)=xi_vec(gridsize)-xi_vec(gridsize-2);
result(6)=k_vec(gridsize)-k_vec(gridsize-2);
end

%YY Function: this function will find suitable range for integration.(LIN)
function result = linrangefinder(XiMin,XiMax,Kmin,Kmax,var_maxvariance,gridsize,a,t,CONST)
xi_vec=linspace(XiMin,XiMax,gridsize);
k_vec=linspace(Kmin,Kmax,gridsize);
[XI,K]=meshgrid(xi_vec,k_vec);
z=integration_kernel(XI,K,a,t,CONST);
zabs=abs(z);
z_xi_scaled=max(zabs,[],1)./max(max(zabs));
z_k_scaled=max(zabs,[],2)./max(max(zabs));

result(1:4)=0;
for tempvar_i=1:gridsize
    if abs(z_xi_scaled(gridsize+1-tempvar_i)) > var_maxvariance && result(2)==0
        result(1)=gridsize+2-tempvar_i;
        if result(1)==gridsize+1
            result(2)=xi_vec(gridsize+1-tempvar_i);
        else
            result(2)=xi_vec(gridsize+2-tempvar_i);
        end
    end
    
    if abs(z_k_scaled(gridsize+1-tempvar_i)) > var_maxvariance && result(4)==0
        result(3)=gridsize+2-tempvar_i;
        if result(3) == gridsize+1
            result(4)=k_vec(gridsize+1-tempvar_i);
        else
            result(4)=k_vec(gridsize+2-tempvar_i);
        end
    end
    
    if result(2)~=0 && result(4)~=0
        break;
    end
end
end


%Main function - gives value for d^2F/(dxi dk)
function result = integration_kernel(xi,k,a,t,CONST)

r_TE_A = r_TE_A_calc(xi,k,t,CONST);
r_TE_B = r_TE_B_calc(xi,k,t,CONST);
r_TM_A = r_TM_A_calc(xi,k,t,CONST);
r_TM_B = r_TM_B_calc(xi,k,t,CONST);

temp_sqrt = sqrt(((xi.^2)./(CONST.c^2)) + k.^2);

temp1 = r_TE_A.*r_TE_B.*exp(-2.*a.*temp_sqrt);
temp2 =  r_TM_A.*r_TM_B.*exp(-2.*a.*temp_sqrt);
result = (CONST.lambda0^4 * 16 /CONST.c) .* k .* temp_sqrt .* ( (temp1./(1-temp1)) + (temp2./(1-temp2)));

end


%----------------reflectivity calculations-----------------
%reflectivity (TE) for plate A
function result = r_TE_A_calc(xi,k,t,CONST)
%{
mu_A = mu_A_calc(xi,k,CONST);
eta_A = eta_A_calc(xi,k,CONST,t);
yy_temp1 = mu_A.*sqrt(xi.^2./((CONST.c)^2) + k.^2);
yy_temp2 = (eta_A).*sqrt(xi.^2/((CONST.c)^2) + k.^2./(eta_A).^2);
result=(yy_temp1-yy_temp2)./(yy_temp1+yy_temp2);
%}
result=-1;
end

%reflectivity (TE) for plate B
function result = r_TE_B_calc(xi,k,t,CONST)

mu_B = mu_B_calc(xi,k,CONST);
eta_B = eta_B_calc(xi,k,CONST,t);
yy_temp1 = mu_B.*sqrt(xi.^2./((CONST.c)^2) + k.^2);
yy_temp2 = (eta_B).*sqrt(xi.^2/((CONST.c)^2) + k.^2./(eta_B).^2);
result=(yy_temp1-yy_temp2)./(yy_temp1+yy_temp2);

end

%reflectivity (TM) for plate A
function result = r_TM_A_calc(xi,k,t,CONST)
%{
epsilon_A = epsilon_A_calc(xi,k,CONST);
eta_A = eta_A_calc(xi,k,CONST,t);
yy_temp1 = epsilon_A.*sqrt(xi.^2./((CONST.c)^2) + k.^2);
yy_temp2 = (eta_A).*sqrt(xi.^2/((CONST.c)^2) + k.^2./(eta_A).^2);
result=(yy_temp1-yy_temp2)./(yy_temp1+yy_temp2);
%}
result=1;
end

%reflectivity (TM) for plate B
function result = r_TM_B_calc(xi,k,t,CONST)

epsilon_B = epsilon_B_calc(xi,k,CONST);
eta_B = eta_B_calc(xi,k,CONST,t);
yy_temp1 = epsilon_B.*sqrt(xi.^2./((CONST.c)^2) + k.^2);
yy_temp2 = (eta_B).*sqrt(xi.^2/((CONST.c)^2) + k.^2./(eta_B).^2);
result=(yy_temp1-yy_temp2)./(yy_temp1+yy_temp2);

end


%----------------Index of refraction-----------------

%Index of refraction for plate A
function eta_A = eta_A_calc(xi,k,CONST,t)
mu_A = mu_A_calc(xi,k,CONST);
epsilon_A = epsilon_A_calc(xi,k,CONST);
eta_A_2 = eta_A_2_calc(xi,k,CONST);
I = I_calc(t,CONST);

[mu_A_angle, mu_A_radius] = cart2pol( real(mu_A), imag(mu_A) );
[epsilon_A_angle, epsilon_A_radius] = cart2pol( real(epsilon_A), imag(epsilon_A) );
eta_A = sqrt(mu_A_radius.*epsilon_A_radius) .* exp(1i./2.*(epsilon_A_angle+mu_A_angle))+eta_A_2.*I;
end

%Index of refraction for plate B
function eta_B = eta_B_calc(xi,k,CONST,t)
mu_B = mu_B_calc(xi,k,CONST);
epsilon_B = epsilon_B_calc(xi,k,CONST);
eta_B_2 = eta_B_2_calc(xi,k,CONST);
I = I_calc(t,CONST);

[mu_B_angle, mu_B_radius] = cart2pol( real(mu_B), imag(mu_B) );
[epsilon_B_angle, epsilon_B_radius] = cart2pol( real(epsilon_B), imag(epsilon_B) );
eta_B = sqrt(mu_B_radius.*epsilon_B_radius) .* exp(1i./2.*(epsilon_B_angle+mu_B_angle))+eta_B_2.*I;
end


%----------------Const calculations-----------------

%Intensity of light
function I = I_calc(t,CONST)
I = 0;
end

%Kerr coefficient for plate A
function eta_A_2 = eta_A_2_calc(xi,k,CONST)
eta_A_2 = 0;
end

%Dielectric constant for plate A
function epsilon_A = epsilon_A_calc(xi,k,CONST)
epsilon_A = NaN;
end

%Permeability for plate A
function mu_A = mu_A_calc(xi,k,CONST)
mu_A = NaN;
end

%Kerr coefficient for plate B
function eta_B_2 = eta_B_2_calc(xi,k,CONST)
eta_B_2 = 0;
end

%Dielectric constant for plate B
function epsilon_B = epsilon_B_calc(xi,k,CONST)
epsilon_B = CONST.var_eps;
end


%Permeability for plate B
function mu_B = mu_B_calc(xi,k,CONST)
mu_B = CONST.var_mu;
end

%ORIGINAL, COOL