Do=get_digital_data()

for i=1:2
    opt{i}=Do{1,i}(:,46)>200;
end

for i=progress(1:size(T,2))
    for h=progress(1:size(T,1))
        R=[];
        scor=[];
        sim=[];
        s=full(T{h,i}.s);
        a=full(T{h,i}.a);
        d=full(T{h,i}.d);
        f=0;
        for j=progress(1:size(opt,2))
            temp_s=s(:,f+1:f+length(opt{1, j}));


            f=f+length(opt{1, j});

            parfor k=1:1000
                sur=circshift_columns(temp_s')';
                sim(:,k)=mean(sur(:,opt{1, j}>0),2);
            end
            r=mean(temp_s(:,opt{1, j}>0),2);

            R(:,j)=abs(r-mean(sim,2))./std(sim,[],2);
        end
         L(h,i)=size(R,1);
        R(isnan(sum(R,2)),:)=[];
        R=double(R>3);
        R(isnan(R))=0;  % all neurons
        R(sum(R,2)==0,:)=[];
       

        %         R(isnan(sum(R,2)),:)=[]; % only neurons active in all sessions

        %     M=mean(1-squareform(1-corr(R,'Rows','pairwise'),'tovector'));
        %   ci = bootci(1000,@(x) mean(1-squareform(1-corr(x,'Rows','pairwise'),'tovector')) ,R);
        M=mean(1-pdist(R','jaccard'));
        ci = bootci(1000,@(x) mean(1-pdist(x','jaccard')),R);

        Score{h,i}=[M,ci(2),ci(1)];
    end
end






