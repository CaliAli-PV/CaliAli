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
rise=1/lognrnd(-0.2139,0.2994,1,1); % parameters obatined from real data
decay=1/lognrnd(-1.7532,0.4346,1,1); % parameters obatined from real data
g = exp(-t/decay)-exp(-t/rise);
temp=A(i,:);
c = conv(temp, g);
out(i,:)=c(1,1:T);
end