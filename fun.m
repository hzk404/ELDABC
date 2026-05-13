function y=fun(x,index)
switch index
    case 1 %Sphere
        y=sum(x.^2);
    case 2%Elliptic
        len=length(x);
        e=[0:len-1]/(len-1);
        y=sum((1000000.^e).*(x.^2));  
    case 3%SumSquare
        len=length(x);
        i=[1:len];
        y=sum(i.*(x.^2));
    case 4%SumPower
        len=length(x);
        i=[2:len+1];
        y=sum(abs(x).^i);
    case 5%Schwefel 2.22
        x_new=abs(x);
        y=sum(x_new)+prod(x_new);
    case 6%Schwefel 2.21
        y=max(abs(x));
    case 7%Step
        newx=floor(x+0.5);
        y=sum(newx.^2);
    case 8%Exponential
        y=exp(0.5*sum(x));
    case 9%Quartic
        len=length(x);
        y=sum([1:len].*(x.^4))+rand;
    case 10 %Rosenbrock
        len=length(x);
        y=0;
        for i=1:len-1
           a=100*(x(i+1)-x(i)^2)^2+(x(i)-1)^2;
           y=y+a;
        end
    case 11%Rastrigin
         s = 0;
        for j = 1:length(x)
            s = s+(x(j)^2-10*cos(2*pi*x(j)));
        end
        y = 10*length(x)+s;
    case 12%NCRastrigin
        y=abs(x);
        index=find(y>=0.5);
        y(index)=round(y(index)*2)/2;
        x=y;
        y=sum(x.^2-10*cos(2*pi*x)+10);
    case 13 %Griewank
        fr = 4000;
        s = 0;
        p = 1;
        for j = 1:length(x); s = s+x(j)^2; end
        for j = 1:length(x); p = p*cos(x(j)/sqrt(j)); end
        y = s/fr-p+1;
    case 14%Schwefel 2.26
        len=length(x);
        y=418.98288727243380*len-sum(x.*sin(sqrt(abs(x))));
    case 15%Ackley
        a = 20; b = 0.2; c = 2*pi;
        s1 = 0; s2 = 0;
        for i=1:length(x)
            s1 = s1+x(i)^2;
            s2 = s2+cos(c*x(i));
        end
        y = -a*exp(-b*sqrt(1/length(x)*s1))-exp(1/length(x)*s2)+a+exp(1);
    case 16%Penalized 1
        y=1+(x+1)/4;
        u=x;
        len=length(x);
        for i=1:len
           if x(i)>10
              u(i)=100*(x(i)-10)^4;
           elseif x(i)<-10
              u(i)=100*(-x(i)-10)^4;
        else
             u(i)=0;
           end
        end
        a=10*sin(pi*y(1))^2;
        b=ones(1,len-1);
        for i=1:len-1
            b(i)=(y(i)-1)^2*(1+10*sin(pi*y(i+1))^2);
        end
        y=pi/len*(a+sum(b)+(y(end)-1)^2)+sum(u);
    case 17%Penalized 2
        u=x;
        len=length(x);
        for i=1:len
           if x(i)>5
              u(i)=100*(x(i)-5)^4;
          elseif x(i)<-5
             u(i)=100*(-x(i)-5)^4;
           else
           u(i)=0;
           end
        end
        a=sin(pi*x(1))^2;
        b=ones(1,len-1);
        for i=1:len-1
        b(i)=(x(i)-1)^2*(1+sin(3*pi*x(i+1))^2)+(x(len)-1)^2*(1+sin(2*pi*x(i+1))^2);
        end
        y=(a+sum(b))/10+sum(u);
    case 18%Alpine
        y=sum(abs(x.*sin(x)+0.1*x));
    case 19%Levy
        len=length(x);
        a=ones(1,len-1);
        for i=1:len-1
          a(i)=(x(i)-1)^2*(1+sin(3*pi*x(i+1))^2);
        end
        y=sum(a)+sin(3*pi*x(1))^2+abs(x(len)-1)*(1+sin(3*pi*x(len))^2);
    case 20%Weierstrass
        a=0.5;b=3;kmax=20;
        len=length(x);
        t=0;
        for i=1:len
          for k=0:kmax
             t=t+a^k*cos(2*pi*b^k*(x(i)+0.5));
          end
        end
        tt=0;
        for k=0:kmax
            tt=tt+a^k*cos(2*pi*b^k*0.5);
        end
        y=t-len*tt;
    case 21%Himmelblau
        len=length(x);
        y=sum(x.^4-16*x.^2+5*x)/len;
    case 22%Michalewicz
        len=length(x);
        a=[1:len].*(x.^2)/pi;
        y=-1*sum(sin(x).*sin(a).^20);
    otherwise
        disp('no such function, please choose another');
end