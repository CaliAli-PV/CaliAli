function P=average_P_same_sessions(P,same_ses_id)

if ~isempty(same_ses_id)
    fprintf(1, 'Generating projections across batches within the same session...\n');
    M=[];
    BV=[];
    Neurons=[];
    PNR = [];
    BVN=[];

    for i=1:max(same_ses_id)
        M=cat(3,M,mean(P.(1){1,1}(:,:,same_ses_id==i),3));
        BV=cat(3,BV,mean(P.(2){1,1}(:,:,same_ses_id==i),3));
        Neurons=cat(3,Neurons,mean(P.(3){1,1}(:,:,same_ses_id==i),3));
        PNR=cat(3,PNR,mean(P.(4){1,1}(:,:,same_ses_id==i),3));
        BVN=cat(4,BVN,uint8(mean(P.(5){1,1}(:,:,:,same_ses_id==i),4)));
    end

    P.(1){1,1}=M;
    P.(2){1,1}=BV;
    P.(3){1,1}=Neurons;
    P.(4){1,1}=PNR;
    P.(5){1,1}=BVN;
end
