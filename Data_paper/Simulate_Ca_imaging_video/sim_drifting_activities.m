function M=sim_drifting_activities(n,ses)
ses=ses/2;
ns1=ceil(n*0.2);
ns2=ceil(n*0.05);

a1=[zeros(ns2,1);ones(ns1,1);zeros(ns1+ns2,1)];
a2=[ones(ns2,1);zeros(ns1,1);zeros(ns1+ns2,1)];
A=[a1,a2];

out=[];
for i=1:size(A,1)
    out(i,:)=linspace(A(i,1),A(i,2),ses);
end
A=out;
A=[A;rand(n-size(A,1),ses)];

b1=[zeros(ns1+ns2,1);zeros(ns2,1);ones(ns1,1)];
b2=[zeros(ns1+ns2,1);ones(ns2,1);zeros(ns1,1)];
B=[b1,b2];
out=[];
for i=1:size(B,1)
    out(i,:)=linspace(B(i,1),B(i,2),ses);
end
B=out;

B=[B;rand(n-size(B,1),ses)];

M=[A,B];
