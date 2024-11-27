function CaliAli_align_sessions(varargin)
% CaliAli_align_sessions();
opt_all=CaliAli_parameters(varargin);
opt=opt_all.inter_session_alignment;
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec','*_mc.h5');
end

opt=detrend_batch_and_calculate_projections(opt,opt_all);
opt.out_path=[opt.output_files{end}(1:end-6),'Aligned.h5'];

opt=match_video_size(opt);

P1=get_stored_projections(opt);

fprintf(1, 'Aligning video by translation ...\n');
[P2,opt.T,opt.T_Mask]=sessions_translate(P1,opt);
fprintf(1, 'Calculating non-rigid aligments...\n');
[opt.shifts,P3,opt.NR_Mask]=get_shifts_alignment(P2,opt);
if opt.final_neurons
    [opt.shifts_n,P4,opt.NR_Mask_n]=get_shifts_alignment(P3,opt,true);
    P=table(P1,P2,P3,P4,'VariableNames',{'Original','Translations','CaliAli','CaliAli+neurons'});
else
    P=table(P1,P2,P3,'VariableNames',{'Original','Translations','CaliAli'});
end
P=BV_gray2RGB(P);
if contains(opt.projections,'BV')
    [P,opt]=evaluate_BV(P,opt);
end
opt.P=P;
opt.alignment_metrics=get_alignment_metrics(P);
opt=apply_transformations(opt);
opt_all.inter_session_alignment=opt;
save_relevant_variables(opt_all);
end

function [P,opt]=evaluate_BV(P,opt)
opt.BV_score=get_BV_NR_score(P,2);
fprintf(1, 'Blood-vessel similarity score: %1.3f \n',opt.BV_score);
if opt.BV_score<2.7 && opt.Force_BVz==0
    fprintf(2, 'Blood-vessel similarity score is too low! \n Results may not be accurate! \n ');
    fprintf(2, 'Aligning utilizing neurons data  \n ');
    P1=P.(1)(1,:);
    [P2,opt.T,opt.T_Mask]=sessions_translate(P1,1);
    fprintf(1, 'Calculating non-rigid aligments...\n');
    [opt.shifts,P3,opt.NR_Mask]=get_shifts_alignment(P2,1);
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

function save_relevant_variables(opt)
P=opt.inter_session_alignment.P;
opt.inter_session_alignment.Cn=max(P.(size(P,2))(1,:).(3){1,1},[],3);
opt.inter_session_alignment.Cn_scale=max(opt.inter_session_alignment.Cn,[],'all');
opt.inter_session_alignment.Cn=opt.inter_session_alignment.Cn./opt.inter_session_alignment.Cn_scale;
opt.inter_session_alignment.PNR=max(P.(size(P,2))(1,:).(4){1,1},[],3);
saveh5(opt,opt.inter_session_alignment.out_path,'append',1,'rootname','CaliAli_options');
end

