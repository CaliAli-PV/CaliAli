function [neuron,prev_F]=propagate_spatials(in,ref)

neuron = Sources2D();
CaliAli_options=CaliAli_load(in,'CaliAli_options');
pars=CaliAli_options.cnmf;
neuron = fill_neuron(neuron, pars);
neuron.options = fill_neuron(neuron.options, pars);
neuron.CaliAli_options=CaliAli_options;
neuron.select_data(in);
neuron.getReady();

evalin( 'base', 'clearvars  filePath fileName mat_*' );


re=load(ref,'neuron');
total_F=sum(neuron.CaliAli_options.inter_session_alignment.F);
prev_F=size(re.neuron.C,2);
neuron.A = re.neuron.A;
K = size(neuron.A, 2);

% folders and files for saving the results
tmp_dir = sprintf('%s%sframes_%d_%d%s', fileparts(neuron.P.mat_file),filesep, 1, total_F, filesep);
if ~exist(tmp_dir, 'dir')
    mkdir(tmp_dir);
end
log_folder = [tmp_dir,  'LOGS_', get_date(), filesep];
log_file = [log_folder, 'logs.txt'];
log_data_file = [log_folder, 'intermediate_results.mat'];
neuron.P.log_folder = log_folder;
neuron.P.log_file = log_file;
neuron.P.log_data = log_data_file;
mkdir(log_folder);

neuron.C=zeros(K,total_F);
neuron.C_raw=nan(K,total_F);
neuron.S=sparse(K,total_F);

neuron.C(:,1:prev_F) = re.neuron.C;
neuron.C_raw(:,1:prev_F) = re.neuron.C_raw;
neuron.S(:,1:prev_F) = sparse(re.neuron.S);
neuron.C_prev=neuron.C;
neuron.A_prev=neuron.A;

neuron.W = re.neuron.W;
neuron.b0 = re.neuron.b0;
neuron.b=re.neuron.b;
neuron.f=re.neuron.f;
neuron.frame_range=[1,total_F];

neuron.P.k_ids = K;
neuron.ids = (1:K);
neuron.tags = zeros(K,1, 'like', uint16(0));
neuron.P.Ymean=re.neuron.P.Ymean;

neuron=update_temporal_CaliAli_targeted(neuron,neuron.use_parallel);




















