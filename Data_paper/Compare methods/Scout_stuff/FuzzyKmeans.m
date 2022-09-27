function [center,u,J,num]=FuzzyKmeans(X,k,q,u,e)
%%����˶��壺X(m*N)��������q��ģ���ȣ�u(N*k)�����ʼ�������Ⱦ���,e����������
%%����˶��壺center(m*k)�����յľ������ģ�u�����յ������Ⱦ���,JΪ׼����ֵ
%%�����������ʼ�����Ⱦ����ټ����ʼ��������
%Author Yun Liu
[m,N]=size(X);
center=zeros(m,k);
u1=zeros(N,k);  %%���ڴ��ǰһʱ�̵�u
error=1;

max_iter=1000;
num=0;
while(error>e)&num<max_iter
    center=(X*u.^q)./(ones(m,1)*sum(u.^q));  %calculation of the new centers of each cluster
    u1=u;
    for i=1:N
        d=sqrt(sum((X(:,i)*ones(1,k)-center).^2,1));
        d=d.^2;
        a=1./d.^(1/(q-1));
        b=sum(a); 
        u(i,:)=a/b;
    end  %%���������Ⱥ���u
    error=max(max(abs(u-u1)));
    num=num+1;
    
end

if num==max_iter
    
    error('did not converge')
end
%%����׼����ֵ
price=zeros(N,k);
for j=1:k
    price(:,j)=u(:,j).*(sum((X-center(:,j)*ones(1,N)).^2))';
end 
J=sum(sum(price));       




