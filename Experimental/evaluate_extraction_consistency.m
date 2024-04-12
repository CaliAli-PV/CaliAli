function [crit,imgComp]=evaluate_extraction_consistency(neuron)
fprintf('\n-----------------Calculating spatial component consistency across sessions----------------------\n');
if size(neuron.A_batch,3)==1
    n2=neuron.copy();
    n2.A_batch=repmat(full(n2.A),1,1,numel(neuron.options.F));
    n2.CaliAli_opt.dynamic_spatial=1;
    n2=update_spatial_CaliAli_dynamic_spatial(n2,1);
    A=n2.A_batch;
else
    A=neuron.A_batch;
end

T=[];
for i=1:size(A,3)
    c=1-squareform(pdist(A(:,:,i)','cosine'));
    L = triu(c,1);
    for k=1:size(L,1)
        t=sort(L(k,:),'descend');
        t(4:end)=[];
        t(t==0)=[];
        T=[T,t];
    end
end
x=0:0.001:1;
T=sort(T);
N = histcounts(T,x);
DCp=1-cumsum(N)./sum(N);
SC=[];
for i=1:size(A,2)
    c=1-pdist(squeeze(A(:,i,:))','cosine');
    SC=[SC,c];
    % cm(i)=sum(c.*(full(weights(i,:))'*full(weights(i,:))),'all');
    cm(i)=min(c);
end

N = histcounts(SC,0:0.001:1);
SCp=cumsum(N)./sum(N);

M=SCp./(SCp+DCp);

for i=1:size(cm,2)
    crit(i)=M(round(cm(i)*999)+1)<0.95;
end

x(1)=[];

figure;
area(x,M); hold on;
area(x,DCp)
area(x,SCp)
ylabel("Probability")
xlabel("Spatial similarity")
legend('Overall Model','Different neurons model','Same neurons model','Location', 'best');
if size(neuron.A_batch,3)==1
    imgComp=see_component_across_sessions(n2,crit);
else
    imgComp=see_component_across_sessions(neuron,crit);
end
implay(imgComp);

