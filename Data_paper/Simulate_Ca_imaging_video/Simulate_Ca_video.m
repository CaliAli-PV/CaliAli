function [out,Mot,outpath,file_name,A]=Simulate_Ca_video(varargin)
% Simulate_Ca_video('motion',0,'save_files',0,'drift',1,'Nneu',100,'ses',2);
% Simulate_Ca_video('Nneu',50,'ses',1,'F',18000,'LFP',8,'spike_prob',[-4.91,0.83],'sf',60);
% Simulate_Ca_video_main(Inputs);

opt=int_var(varargin);
outpath=get_out_path(opt);
% set random seed
s=rng(opt.seed);

%% Create Baselines for two sessions;
bl=create_baseline(opt);

%% create neural data
[A_in,bA_in,C,S,LFP]=create_neuron_data(opt);
opt.Nneu2=size(A_in,3);
%% Apply overlapping mask to C
C=add_remapping_drifting(C,opt);

%% add Non-Rigid motion to sessions
[BL(:,:,1),A{1,1},bA{1,1},Mot{1}]=Add_NRmotion(bl(:,:,1),A_in,bA_in,0,opt.plotme,opt.translation);
for i=2:opt.ses
    [BL(:,:,i),A{1,i},bA{1,i},Mot{i}]=Add_NRmotion(bl(:,:,i),A_in,bA_in,opt.motion,opt.plotme,opt.translation);
end
%% create noise data
[d1,d2]=size(BL(:,:,1));
N=rand(d1,d2,opt.F*opt.ses);
N=imgaussfilt(N);
N=N-mean(N,3);


%% Integrate model
out=cell(1,opt.ses);
ix1=1;
F=opt.F;
ix2=F;
PNR=opt.PNR;
mult=0.8;  %% BL proportion to total signal.
for i=1:opt.ses
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
if opt.save_files

    file_name=datestr(now,'yymmdd_HHMMSS');
    for i=1:opt.ses
        saveash5(out{1,i},[file_name,'_ses',sprintf( '%02d',i-1)]);
    end
    saveash5(GT,[file_name,'_GT']);
    seed=s.Seed;

    opt.seed=seed;
    save([file_name,'.mat'],'A','C','S','BL','seed','opt','Mot','LFP');
else
    file_name=[];
end

end

function opt=int_var(varargin)
%% INTIALIZE VARIABLES
inp = inputParser;
valid_v = @(x) isnumeric(x);
addParameter(inp,'outpath',[])
addParameter(inp,'min_dist',8,valid_v)
addParameter(inp,'Nneu',50,valid_v)
addParameter(inp,'PNR',2,valid_v)
addParameter(inp,'d',[220,300],valid_v)
addParameter(inp,'F',1000,valid_v)
addParameter(inp,'overlap',1,valid_v)
addParameter(inp,'overlapMulti',1,valid_v)
addParameter(inp,'motion',0,valid_v)
addParameter(inp,'ses',2,valid_v)
addParameter(inp,'seed','shuffle' )
addParameter(inp,'B',1)
addParameter(inp,'spike_prob',[-4.9,2.25]); %% this is in log scale mean and std
addParameter(inp,'save_files',true);
addParameter(inp,'create_mask',true);
addParameter(inp,'translation',1,valid_v)
addParameter(inp,'comb_fact',0,valid_v)
addParameter(inp,'drift',0,valid_v)
addParameter(inp,'LFP',0,valid_v)
addParameter(inp,'sf',10,valid_v)
addParameter(inp,'plotme',0,valid_v) 
addParameter(inp,'invtRise',[2.08,0.29],valid_v) % this is in log scale
addParameter(inp,'invtDecay', [0.55,0.44],valid_v) % this is in log scale
varargin=varargin{1, 1};

inp.KeepUnmatched = true;
parse(inp,varargin{:});
opt=inp.Results;
end

function  outpath=get_out_path(opt)
if opt.save_files
    if isempty(opt.outpath)
        outpath = uigetdir(pwd,'select output folder');
    else
    outpath=opt.outpath;
    end
    cd(outpath);
else
    outpath=[];
end
end

function bl=create_baseline(opt)
comb_fact=1-opt.comb_fact;
ses=opt.ses;
load('BL.mat','Mr');

if length(opt.B)==1
    Mr=Mr{opt.B,1};
    bl=zeros(opt.d(1),opt.d(2),2);
    for i=1:size(Mr,3)
        bl(:,:,i)=imresize(Mr(:,:,i),opt.d);
    end
    if ses>2
        p=rand(1,ses);
        temp=bl;
        bl=zeros(opt.d(1),opt.d(2),ses);
        for i=1:ses
            bl(:,:,i)=temp(:,:,1)*p(i)+temp(:,:,2)*(1-p(i))+randn/10;
        end
        bl=mat2gray(bl);
    end
else
    temp=cat(3,imresize(Mr{B(1),1}(:,:,1),opt.d),imresize(Mr{B(2),1}(:,:,1),opt.d));
    p=linspace(1,comb_fact,ses);

    for i=1:ses
        bl(:,:,i)=temp(:,:,1)*p(i)+temp(:,:,2)*(1-p(i));
    end

end
end

function C=add_remapping_drifting(C,opt)
Nneu2=opt.Nneu2;
ses=opt.ses;
F=opt.F;
if ses>1
    temp=double(rand(Nneu2,ses)<=opt.overlap);
    t2=repelem(eye(ses),ceil(Nneu2/ses),1);
    t2(randi(size(t2,1),1,size(t2,1)-size(temp,1)),:)=[];
    temp=(temp+t2)>0;
    M=double(repelem(temp,1,F));
    M(M==0)=opt.overlapMulti;
else
    M=ones(Nneu2,F);
end
C=C.*M;

if opt.drift==1
     M=sim_drifting_activities(Nneu2,ses);
    M=double(repelem(M,1,F));
    C=C.*M;
end
end



