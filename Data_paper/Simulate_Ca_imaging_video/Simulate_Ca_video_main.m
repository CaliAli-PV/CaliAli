function [out,Mot,outpath,file_name,A]=Simulate_Ca_video_main(varargin)
% [out,Mot,outpath,file_name,A]=Simulate_Ca_video_main('motion',5,'overlap',1,'overlapMulti',1','min_dist',10,'Nneu',100,'SNR',2,'save_files',false);
%  Simulate_Ca_video_main('motion',0,'overlap',1,'overlapMulti',0.25','min_dist',6,'Nneu',150,'SNR',0.5);
% Simulate_Ca_video_main('motion',0,'save_files',0,'spike_prob',"[-5,0]",'drift',1,'Nneu',100,'ses',20);
% Simulate_Ca_video_main(Inputs);

%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
addParameter(inp,'outpath',[])
addParameter(inp,'min_dist',8,valid_v)
addParameter(inp,'Nneu',50,valid_v)
addParameter(inp,'PNR',2,valid_v)
addParameter(inp,'d1',220,valid_v)
addParameter(inp,'d2',300,valid_v)
addParameter(inp,'F',1000,valid_v)
addParameter(inp,'overlap',1,valid_v)
addParameter(inp,'overlapMulti',1,valid_v)
addParameter(inp,'motion',0,valid_v)
addParameter(inp,'ses',2,valid_v)
addParameter(inp,'seed','shuffle' )
addParameter(inp,'B',1)
addParameter(inp,'spike_prob',[-7.2,1.1]);
addParameter(inp,'save_files',true);
addParameter(inp,'create_mask',true);
addParameter(inp,'translation',1,valid_v)
addParameter(inp,'comb_fact',0,valid_v)
addParameter(inp,'drift',0,valid_v)
inp.KeepUnmatched = true;
parse(inp,varargin{:});
warning off

outpath=inp.Results.outpath;
min_dist=inp.Results.min_dist;
spike_prob=str2num(inp.Results.spike_prob);
Nneu=inp.Results.Nneu;
PNR=inp.Results.PNR;
d1=inp.Results.d1;
d2=inp.Results.d2;
F=inp.Results.F;
motion=inp.Results.motion;
translation=inp.Results.translation;
overlap=inp.Results.overlap;
ses=inp.Results.ses;
seed=inp.Results.seed;
overlapMulti=inp.Results.overlapMulti;
comb_fact=inp.Results.comb_fact;
B=inp.Results.B;
save_files=inp.Results.save_files;
create_mask=inp.Results.create_mask;
drift=inp.Results.drift;
% set random seed
if save_files
    if isempty(outpath)
        outpath = uigetdir(pwd,'select output folder');
    end
    cd(outpath);
else
    outpath=[];
end
s=rng(seed);


%% Create Baselines for two sessions;
bl=create_base_line(d1,d2,string(B),ses,comb_fact);

%% create neural data
[A_in,bA_in,C]=create_neuron_data(d1,d2,min_dist,Nneu,F,ses,0,spike_prob,create_mask);
Nneu=size(A_in,3);
%% Apply overlapping mask to C
if ses>1
    temp=double(rand(Nneu,ses)<=overlap);
    t2=repelem(eye(ses),ceil(Nneu/ses),1);
    t2(randi(size(t2,1),1,size(t2,1)-size(temp,1)),:)=[];
    temp=(temp+t2)>0;
    M=double(repelem(temp,1,F));
    M(M==0)=overlapMulti;
else
    M=ones(Nneu,F);
end
C=C.*M;

if drift==1
     M=sim_drifting_activities(Nneu,ses);
    M=double(repelem(M,1,F));
    C=C.*M;
%     plot_High_dimension_drift(C);
%     plot_hyper_plane_projection(bin_data(C,1,100)')
end

%% add Non-Rigid motion to sessions
[BL(:,:,1),A{1,1},bA{1,1},Mot{1}]=Add_NRmotion(bl(:,:,1),A_in,bA_in,0,0,translation);
for i=2:ses
    [BL(:,:,i),A{1,i},bA{1,i},Mot{i}]=Add_NRmotion(bl(:,:,i),A_in,bA_in,motion,0,translation);
end
%% create noise data
[d1,d2]=size(BL(:,:,1));

N=rand(d1,d2,F*ses);
N=imgaussfilt(N);
N=N-mean(N,3);


%% Integrate model
out=cell(1,ses);
ix1=1;
ix2=F;
mult=0.8;  %% BL proportion to total signal.
for i=1:ses
    V=reshape(reshape(A{i},d1*d2,[])*C(:,ix1:ix2),d1,d2,[]);
    LB=reshape(reshape(bA{i},d1*d2,[])*C(:,ix1:ix2),d1,d2,[]);
    tn=N(:,:,ix1:ix2);
    FV=mult*BL(:,:,i)+  (1-mult)*(V+LB)*(1/(1/PNR+1))   +   (1-mult)*tn*(1-1/(1/PNR+1)); %add data
    FV=FV./max(FV,[],'all');  %
    FV=uint16(FV*2^16);
    out{1,i}=FV;
    ix1=ix1+F;
    ix2=ix2+F;
end
GT=reshape(reshape(A{1},d1*d2,[])*C,d1,d2,[])+reshape(reshape(bA{1},d1*d2,[])*C,d1,d2,[])*(1/(1/PNR+1)) +N.*(1-1/(1/PNR+1));
GT=GT-min(GT,[],'all');
GT=GT./max(GT,[],'all');
GT=uint16(GT*2^16);%
%% Save results
if save_files

    file_name=datestr(now,'yymmdd_HHMMSS');
    try
        %  export_fig([file_name,'_motion.pdf'], '-append');
    catch
    end

    for i=1:ses
        saveash5(out{1,i},[file_name,'_ses',sprintf( '%02d',i-1)]);
    end
    saveash5(GT,[file_name,'_GT']);
    seed=s.Seed;

    Inputs=inp.Results;
    Inputs.seed=seed;
    save([file_name,'.mat'],'A','C','BL','seed','Inputs','Mot');
else
    file_name=[];
end

end


function bl=create_base_line(d1,d2,B,ses,comb_fact)
comb_fact=1-comb_fact;
B=str2num(B);
load('BL.mat','Mr');

if length(B)==1
    Mr=Mr{B,1};
    bl=zeros(d1,d2,2);
    for i=1:size(Mr,3)
        bl(:,:,i)=imresize(Mr(:,:,i),[d1 d2]);
    end

    if ses>2
        p=rand(1,ses);
        temp=bl;
        bl=zeros(d1,d2,ses);
        for i=1:ses
            bl(:,:,i)=temp(:,:,1)*p(i)+temp(:,:,2)*(1-p(i))+randn/10;
        end
        bl=mat2gray(bl);
    end
else

    temp=cat(3,imresize(Mr{B(1),1}(:,:,1),[d1 d2]),imresize(Mr{B(2),1}(:,:,1),[d1 d2]));
    p=linspace(1,comb_fact,ses);

    for i=1:ses
        bl(:,:,i)=temp(:,:,1)*p(i)+temp(:,:,2)*(1-p(i));
    end

end

end








