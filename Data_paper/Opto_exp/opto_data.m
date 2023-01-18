function [R_sa,L,Sc_M,Active_both_sessions]=opto_data(T,opt)

% [R_sa,L,Sc_M,Sc_M_Active,Active_both_sessions]=opto_data(T,opt);
for i=1:size(T,2)
    thr=0.1:0.1:10;
    for t=1:length(thr)
        for h=1:size(T,1)-1
            R=[];
            scor=[];
            sim=[];
            active=[];
            cr=full(T{h,i}.cr);
            s=full(T{h,i}.s);
            a=full(T{h,i}.a);
            d=full(T{h,i}.d);
            f=0;
            for j=1:size(opt,2)
                temp_cr=cr(:,f+1:f+length(opt{1, j}));
                temp_s=s(:,f+1:f+length(opt{1, j}));
                active(:,j)=mean(temp_s>0,2)>0;
                R(:,j)=get_opto_responding(temp_cr,opt{1, j});
                f=length(opt{1, j});
            end
            R_sa{h,t,i}=R;
            R=double(R>thr(t));
            L(h,t,i)=sum(sum(R,2)>0)/size(R,1);% proportion neurons responding to light in at least one session
            op_res=sum(R,2)==0;%% only neurons responding in at least one session.
            Active_both_sessions(h,t,i)=sum(prod(active,2))/length(active);
            R(op_res,:)=[];
            active(op_res,:)=[];
            active=logical(prod(active,2));%% only neurons active in both sessions

            M=mean(1-pdist(R','jaccard'));
            M_active=mean(1-pdist(R(active,:)','jaccard'));
            Sc_M(h,t,i)=M;
            Sc_M_Active(h,t,i)=M_active;           
        end
    end
end
Sc_M=arrange_mat(Sc_M);
L=arrange_mat(L);
Active_both_sessions=squeeze(Active_both_sessions(:,1,:));
end
function M=arrange_mat(M)
M=table(M(:,:,1)',M(:,:,2)',M(:,:,3)','VariableNames',{'CaliAli','CellReg','SCOUT'});
end










