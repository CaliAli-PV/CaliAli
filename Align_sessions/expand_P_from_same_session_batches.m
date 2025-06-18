function [P,shifts]=expand_P_from_same_session_batches(P,shifts,ses_id)

if ~isempty(ses_id)
    [d1,d2,~]=size(P.(1){1,1});
    M=zeros(d1,d2,numel(ses_id));
    BV=zeros(d1,d2,numel(ses_id));
    Neurons=zeros(d1,d2,numel(ses_id));
    PNR = zeros(d1,d2,numel(ses_id));
    BVN=zeros(d1,d2,numel(ses_id));
    S=zeros(size(shifts,1),size(shifts,2),2,numel(ses_id));


    for i=1:max(ses_id)
        M(:,:,ses_id==i)=repmat(P.(1){1,1}(:,:,unique(ses_id)==i),1,1,sum(ses_id==i));
        BV(:,:,ses_id==i)=repmat(P.(2){1,1}(:,:,unique(ses_id)==i),1,1,sum(ses_id==i));
        Neurons(:,:,ses_id==i)=repmat(P.(3){1,1}(:,:,unique(ses_id)==i),1,1,sum(ses_id==i));
        PNR(:,:,ses_id==i)=repmat(P.(4){1,1}(:,:,unique(ses_id)==i),1,1,sum(ses_id==i));
        BVN(:,:,ses_id==i)=repmat(P.(5){1,1}(:,:,unique(ses_id)==i),1,1,sum(ses_id==i));
        S(:,:,:,ses_id==i)=repmat(shifts(:,:,:,unique(ses_id)==i),1,1,1,sum(ses_id==i));
    end

    P.(1){1,1}=M;
    P.(2){1,1}=BV;
    P.(3){1,1}=Neurons;
    P.(4){1,1}=PNR;
    P.(5){1,1}=BVN;
    shifts=S;
end

