function y = lol(x,times)
y=zeros(1,times);
y(1)=x;
for i=2:times
    y(i)=x.^y(i-1);
    sprintf('For %d, y=%e\n',i,y(i));
end
plot(y);
end



%{
%numerical approximation to x^x^x....=2
function y = lol(testlength)
%y=zeros(1,testlength);
%for i=1:testlength
    y=fzero(@(x) x.^x-2,0.1);
    %sprintf('For Testlength=%d, answer =%e',i,y(i));
%end
end

function result = infp(x,times)
    
    result=x.^x .^x- 2;
end




    a=x;
    for i=1:times
        a=a.^x;
        sprintf('%d\n',i);
    end

%}