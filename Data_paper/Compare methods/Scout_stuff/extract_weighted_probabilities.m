function probabilities=extract_weighted_probabilities(weights,corr_prob,dist_prob)
% if weights(1)>0&exist('corr_prob','var')&~isempty(corr_prob)
%     prob=corr_prob;
% else
%     prob=[];
%     weights(1)=[];
% end
% if isempty(prob)
%     prob=vertcat(dist_prob{:})';
% else
%     prob(:,end+1:length(dist_prob)+1)=vertcat(dist_prob{:})';
% end
%prob(isnan(prob))=0;
dist_prob=horzcat(dist_prob{:});
%dist_prob(isnan(dist_prob))=0;
if weights(1)>0&exist('corr_prob','var')&~isempty(corr_prob)
    use_corr=true;
    prob=horzcat(corr_prob,dist_prob);
else
    use_corr=false;
    corr_prob=zeros(size(dist_prob,1),1);
    prob=horzcat(corr_prob,dist_prob);
end

% consensus_matrices=zeros(size(prob,1),size(prob,1),100);
% curr_weights=zeros(100,length(weights));
% parfor j=1:100
%     curr_weights(j,:)=generate_weights(weights);
%    
%     
%     curr_prob=sum(curr_weights(j,:).*prob,2);
%     consensus_matrices(:,:,j)=bsxfun(@lt,curr_prob,curr_prob');
% end
% consensus_matrix=mean(consensus_matrices,3);
% %consensus_matrix(consensus_matrix<.5)=0;
% %consensus_matrix(consensus_matrix>=.5)=1;
% consensus_score=mean(abs(consensus_matrices-consensus_matrix),[1,2]);
% [~,I]=min(consensus_score);
% 
% % if isempty(corr_prob)
% %     curr_weights(I,:)=[5,6,8]/(5+6+8);
% % else
% %     curr_weights(I,:)=[4,5,6,8]/(4+5+6+8);
% % end
%curr_weights(I,:)=weights;
%probabilities=zeros(size(prob,1),1);
% total=prob(:,2:4).*weights(2:4);
% if use_corr
%     ind=find(~isnan(corr_prob));
%     total(ind,1)=weights(1)*corr_prob(ind);
%     total(~ind,1)=nan;
%     probabilities(ind)=sum(weights.*prob(ind,:),2);
%     ind=setdiff(1:length(corr_prob),ind);
%     weights(1)=0;
%     weights=weights/sum(weights);
%     prob(isnan(prob))=0;
%     probabilities(ind)=sum(weights.*prob(ind,:),2);
% else
%     probabilities=sum(weights.*prob,2);
% end
% for j=4:5
%     if weights(j)>0
%         
% end
for k=1:size(prob,1)
    probabilities(k)=sum(prob(k,:).*weights,'omitnan')/sum(weights(~isnan(prob(k,:))));
end

    
