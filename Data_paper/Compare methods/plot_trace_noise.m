bar(Noise_sparse.CaliAli(1,1).m(:,1),Noise_sparse.CaliAli(1,1).m(:,2));
hold
bar(Noise_sparse.CellReg(1,1).m(:,1),Noise_sparse.CellReg(1,1).m(:,2));

figure;
ix=6;

t(:,1)=C(ix,:);
t(:,2)=Noise_sparse.CaliAli(1,1).cr(find(Noise_sparse.CaliAli(1,1).m(:,1)==ix),:)';
t(:,3)=Noise_sparse.CellReg(1,1).cr(find(Noise_sparse.CellReg(1,1).m(:,1)==ix),:)';
t(:,4)=Noise_sparse.SCOUT(1,1).cr(find(Noise_sparse.SCOUT(1,1).m(:,1)==ix),:)';

 t=t./max(t,[],1);

stackedplot(t);