function align_sessions_CaliAli(varargin)
% align_sessions_CaliAli();
opt=int_var(varargin);
if ~isfile(opt.out)
    [opt.Mask,~]=get_mask_and_F(opt.theFiles);
end
opt=detrend_batch_and_calculate_projections(opt);
P1=get_stored_projections(opt);

if opt.UseBV==0
    fprintf(2, 'Aligning utilizing neurons data  \n ');
    P1.(2){1,1}=P1.(3){1,1};
end
fprintf(1, 'Aligning video by translation ...\n');
[P2,opt.T,opt.T_Mask]=sessions_translate(P1);
fprintf(1, 'Calculating non-rigid aligments...\n');
[opt.shifts,P3,opt.NR_Mask]=get_shifts_alignment(P2);
if opt.FinalAlignmentWithNeuronShapes
    [opt.shifts_n,P4,opt.NR_Mask_n]=get_shifts_alignment_only_neurons(P3);
    P=table(P1,P2,P3,P4,'VariableNames',{'Original','Translations','CaliAli','CaliAli+neurons'});
else
    P=table(P1,P2,P3,'VariableNames',{'Original','Translations','CaliAli'});
end
P=BV_gray2RGB(P);
if opt.UseBV==1
    [P,opt]=evaluate_BV(P,opt);
end

T=get_alignment_metrics(P);
T
apply_transformations(opt);
save_relevant_variables(P,opt,T)
end

function [P,opt]=evaluate_BV(P,opt)
opt.BV_score=get_BV_NR_score(P,2);
fprintf(1, 'Blood-vessel similarity score: %1.3f \n',opt.BV_score);
if opt.BV_score<2.7 && opt.Force_BVz==0
    fprintf(2, 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n ');
    fprintf(2, 'Aligning utilizing neurons data  \n ');
    P1=P.(1)(1,:);
    P1.(2){1,1}=P1.(3){1,1};
    [P2,opt.T,opt.T_Mask]=sessions_translate(P1);
    fprintf(1, 'Calculating non-rigid aligments...\n');
    [opt.shifts,P3,opt.NR_Mask]=get_shifts_alignment(P2);
    [opt.shifts_n,P4,opt.NR_Mask_n]=get_shifts_alignment_only_neurons(P3);
    if opt.FinalAlignmentWithNeuronShapes
        [opt.shifts_n,P4,opt.NR_Mask_n]=get_shifts_alignment_only_neurons(P3);
        P=table(P1,P2,P3,P4,'VariableNames',{'Original','Translations','CaliAli','CaliAli+neurons'});
    else
        P=table(P1,P2,P3,'VariableNames',{'Original','Translations','CaliAli'});
    end
    P=BV_gray2RGB(P);
end
get_neuron_projections_correlations(P,3);
end

function save_relevant_variables(P,opt,T)
Cn=max(P.(size(P,2))(1,:).(3){1,1},[],3);
opt.Cn_scale=max(Cn,[],'all');
Cn=Cn./opt.Cn_scale;
PNR=max(P.(size(P,2))(1,:).(4){1,1},[],3);
BV_score=opt.BV_score;
F=opt.F;
n_enhanced=opt.n_enhanced;
if ~isfile(opt.out_mat)
    save(opt.out_mat,'P','BV_score','Cn','PNR','F','n_enhanced','opt','T');
else
    save(opt.out_mat,'P','BV_score','Cn','PNR','F','n_enhanced','opt','-append','T');
end
end

