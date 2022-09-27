function [idx,k] = kmedoids_cluster_constrained(X, k,chain_prob,num_sessions,session_ids)

for l=1:max(session_ids)
    ind=find(session_ids==l);
    X(ind,ind)=-10000000;
end
for l=1:size(X,1)
    X(l,l)=1;
end

[a,b]=groupcounts(session_ids');
[M,I]=max(a);
start=find(session_ids==b(I));
if length(start)<k
    remain=setdiff(1:length(session_ids),start);
    perm=randperm(length(remain),k-length(start));
    start=[start,remain(perm)];
end

[idx,k]=cluster_initialize(k,session_ids,1-X,chain_prob);
%idx=reshape(1:size(X,1),[],1);
[idx,start,k]=avg_cluster_temp(1-X,max(idx),idx,start,max(length(session_ids),30),100,session_ids,chain_prob);

[idx,start,k]=avg_cluster_temp(1-X,k,idx,start,25,.002,session_ids,chain_prob);

% 
% 
% iter=1;
% while true
%     iter=iter+1;
%     break_loop=true;
%     idx_old=idx;
%     
%     while true
%     prob=0;
%     for l=1:max(idx)
%         nodes=find(idx==l);
%         curr_mat=X(nodes,nodes);
%         node_prob=1-(sum(curr_mat<=0,'all'))/(length(nodes)^2);
%       
%         if node_prob<chain_prob || length(nodes)>num_sessions ||sum(X(nodes,nodes)<0,'all')>0
%             prob=prob+1;
%             break_loop=false;
%             vals=sum(curr_mat,1);
%             [~,I]=min(vals);
%             idx(nodes(I))=max(idx)+1;
%             start(end+1)=nodes(I);
%             k=k+1;
%             break
%         end
%     end
%     if prob==0
%         break
%     end
%     end
%     if iter>=10
%         break
%     end
% %     if idx==idx_old
% %         break
% %     end
%     [idx,start,k]=avg_cluster(1-X,k,idx,start,25,.002,session_ids,chain_prob);
%     if break_loop
%         while true
%             break_secondloop=true;
%         for q=1:max(idx)
%             nodes=find(idx==q);
%             sessions=session_ids(nodes);
%             if length(unique(sessions))~=length(sessions)
%                 break_secondloop=false;
%                 [~,uniq_vals]=unique(sessions);
%                 dup=sessions(setdiff(1:length(sessions),uniq_vals));
%                 dup_nodes=nodes(ismember(sessions,dup));
%                 vals=sum(X(dup_nodes,nodes),2);
%                 [~,I]=min(vals);
%                 
%                 
%                 poss_clust=zeros(1,max(idx));
%                 for l=1:max(idx)
%                     if l~=q
%                         tempnode=find(idx==l);
%                         tempnode1=[tempnode;nodes(I)];
%                         poss_clust(l)=1-(sum(X(tempnode1,tempnode1)==0,'all')-length(tempnode1))/(length(tempnode1)^2-length(tempnode1))+10^(-6)*mean(X(tempnode1,tempnode1),'all');
%                         if ismember(sessions(I),session_ids(tempnode));
%                             poss_clust(l)=0;
%                         end
%                     end
%                 end
%                 
%                 [M,J]=max(poss_clust);
%                 if M>chain_prob
%                     idx(nodes(I))=J;
%                 else
%                     idx(dup_nodes(I))=max(idx)+1;
%                     start(end+1)=dup_nodes(I);
%                     k=k+1;
%                     
%                 end
%             end
%             
%         end
%         if break_secondloop==true
%             break
%         end
%         end
%             
%         if break_loop
%             break
%         end
%     end
%                 
%             
%             
%         
%         
%         
%     end
%     
for j=1:max(idx)
    dup=~(length(session_ids(idx==j))==length(unique(session_ids(idx==j))));
    temp_one=sum(X(idx==j,idx==j)<=0,'all');
    temp_one_score=temp_one/((sum(idx==j))^2-(sum(idx==j)));
    
end  

[idx,start,k]=avg_cluster_temp(1-X,k,idx,start,10*length(unique(session_ids)),.002,session_ids,chain_prob);
for j=1:max(idx)
    dup=~(length(session_ids(idx==j))==length(unique(session_ids(idx==j))));
    temp_one=sum(X(idx==j,idx==j)<=0,'all');
    temp_one_score=temp_one/((sum(idx==j))^2-(sum(idx==j)));
    
end                 

end    
    
    


