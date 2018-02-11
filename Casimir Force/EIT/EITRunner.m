precisionX=10000;
Xspace=linspace(-5,5,precisionX);
Yspace=zeros(1,precisionX);
Zspace=zeros(1,precisionX);

for i=1:precisionX
result=EITSusceptibility(Xspace(i));
Yspace(i)=real(result);
Zspace(i)=imag(result);
end
XSpespace=1-Xspace;
plot(XSpespace,Yspace,XSpespace,Zspace);
