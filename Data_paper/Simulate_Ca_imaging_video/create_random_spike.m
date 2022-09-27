function out=create_random_spike(N,T,P)

% out=create_random_spike(100,6000);

for i=1:N
    p=P(i);
    temp=binornd(1,p,T,1);
    if sum(temp)==0
        temp(randi(length(temp),1))=1;
    end
    A(i,:)=temp;
end




t = 0:T-1; %  From Monitoring Brain Activity with Protein Voltage and Calcium Sensors. Fig 4. For frame rate on 10 fps.




for i=1:size(A,1)
f = abs(2.5+randn/5); %
tau = 11+randn; % 
g = exp(-t/tau)-exp(-t/f);
temp=A(i,:);
c = conv(temp, g);
out(i,:)=c(1,1:T);
end