function [out,W]=get_neuron_projections_correlations(P,k)
if ~exist('k','var')
k=3;
end
C=P.(3)(1,:).(k){1,1};
fprintf(1, 'Calculating correlation of the %s projections... \n ',P.(3)(1,:).Properties.VariableNames{k});
[d1,d2,d3]=size(C);
B=nchoosek(1:d3,2);
for i=progress(1:size(B,1))
    NC=normxcorr2(C(:,:,B(i,1)),C(:,:,B(i,2)));
    cs=size(NC);
    NC=NC(round(cs(1)/2-cs(1)/6):round(cs(1)/2+cs(1)/6)...
        ,round(cs(2)/2-cs(2)/6):round(cs(2)/2+cs(2)/6));%% 1/6 of the total length
    % MPC(i)=median(NC(:));
     MPC(i,:)=[mean(NC(:)),std(NC(:))];
end

C=reshape(C,d1*d2,d3);

Cor=1-squareform(pdist(C','correlation'));
W= rescale(mean(Cor-eye(size(Cor,1)),2))+0.2;
W=W./sum(W);
if k==3;
D=(Cor-squareform(MPC(:,1)));
Sc=tril(D<0.2); %%  This criteria is the one used by CellReg
else
D=(Cor-squareform(MPC(:,1)))./squareform(MPC(:,2));
Sc=tril(D<4.35);
end
[low_correlation_sessions(:,2),low_correlation_sessions(:,1)] = ind2sub([size(Sc,1),size(Sc,1)],find(Sc));
if ~isempty(low_correlation_sessions)
    fprintf(2, 'Warning! \n Some %s projections display low correlation\n',P.(3)(1,:).Properties.VariableNames{k});
    % low_correlation_sessions
else
fprintf(1, 'Correlation between %s projections is good! \n Lowest spatial correlation: %1.3f \n',P.(3)(1,:).Properties.VariableNames{k},min(Cor,[],'all'));
end

out=min(D,[],'all');


