function [neuron,cell_register,neurons,links]=cellTracking_SCOUT(neurons,varargin)
%Author: Kevin Johnston
%Main function for cell registration between sessions
%Inputs
%neurons (cell of class Sources2D objects containing neural data from each
%           session, A,C,imageSize required entries)
%Optional Inputs (input as 'parameter_name', parameter in function)
%  links: (cell array of Sources2D) extractions of connecting sesssions, required for correlation
%               registration. Cell of Sources2D structs

%  overlap: (int) temporal overlap between connecting sessions
%  max_dist: (float (or vector of floats) ) max distance between registered neurons
%       between sessions (multiple entries will return multiple cell registers)
%  weights: (vector (or matrix, each row corresponding to a weight set)) weights for linking methods. 4 element numeric vector. Order correlation, JS, overlap, centroid dist
%  chain_prob: (float or vector of floats range [0,1]) Total probability threshold for neuron chains, numeric value between 0 and 1
%  corr_thresh (float range [0,1]) Probability threshold for correlation link
%               between neurons, numeric value between 0 and 1. Usually 0
%               unless binary_corr is true
%  patch: (int) Patch size if neuron density varies significantly across the
%               recording (currently has no effect.  "in progress")
%  register_sessions: (bool) indicating whether to register sessions.
%       Default true
%  registration_type: (str) 'align_to_base' or 'consecutive', Determines if
%       sessions are registered to base session, or registered
%       consecutively.
%  registration_method: (cell of strings) 'translation', 'similarity','affine' or 'non-rigid', method for session
%       registration. If given a cell of strings, registrations will be
%       performed consecutively
%  registration_template: (str) Use spatial positions of neurons 'spatial', or
%       correlation map 'correlation' for registration
%  use_corr: (boolean) indicating whether to use correlation cell registration
%           requires links
%  use_spat: (boolean) indicating whether to use spatial cell registration.
%       This should be false only if resources are low, or registration
%       cannot be guaranteed between all sessions
%   max_gap: (int) indicating largest gap between sessions for cell
%       registration. 0 indicates cells must appear in each session
%   probability_assignment_method: (str) either 'percentile', 'gmm',
%       'gemm','glmm' or 'Kmeans'
%   base: (int range [1,length(neurons)]) base session for alignment
%   min_prob: (float or vector of floats, range [0,1]) minimum probability for identification between
%   sessions
%   binary_corr: (bool) treat correlation on connecting recordings as binary
%      variable
%   max_sess_dist: (int) limits number of compared sessions to reduce
%     runtime. Leave as [] for no reduction, currently doesn't work,
%     defaults to inf.
%   footprint_threshold (float range [0,1]) percentile to threshold
    %   spatial footprints
%   single_corr (bool) use this if correlation is to be calculated only on
%       the second recording in each consecutive pair (this should almost
%       always be false)
%   scale_factor (positive float) Controls search radius for cell tracking lower to constrain search parameters.
%   reconstitute (bool) determine whether to reconstitute neuron chains.
%       Set to false if cell tracking many sessions (>15)
%   cell_tracking_options (struct) with fields that contains some or all previously stated optional
    %   parameters
% Outputs
%  neuron: (Sources2D) containing neural activity extracted through the set
%           of sessions
%  cell_register: (matrix) Registration Indices Per Session for each identified cell
%  


%% Assign variables
%tic
optional_parameters={'links','weights','max_dist','overlap','chain_prob','corr_thresh','register_sessions','registration_type','registration_method',...
    'registration_template','use_corr','use_spat','max_gap','probability_assignment_method','base','min_prob','binary_corr','max_sess_dist',...
    'footprint_threshold','cell_tracking_options','single_corr','scale_factor','reconstitute','construct_combined'};
defaults={{},[4,5,5,0,0,0],[45],[],[.5],.6,true,'align_to_base',{'affine','non-rigid'},'spatial',false,true,0,'default',ceil(length(neurons)/2),[.5],false,inf,0,struct,false,1.5,true,true};

p=inputParser;

addRequired(p,'neurons');
for i=1:length(optional_parameters)
    addOptional(p,optional_parameters{i},defaults{i},@(x) isequal(class(defaults{i}),class(x))||isempty(x)); 
end

parse(p,neurons,varargin{:});
for i=1:length(p.Parameters)
    if isfield(p.Results.cell_tracking_options,p.Parameters{i})
        val=getfield(p.Results.cell_tracking_options,p.Parameters{i});
    else
        val=getfield(p.Results,p.Parameters{i});
    end
    eval([p.Parameters{i},'=val',';'])
end
if isempty(links)
    weights(:,1)=0;
    overlap=0;
    corr_thresh=[];
    links=[];
end
if isequal(registration_template,'correlation')&isempty(neurons{1}.Cn)
    registration_template='spatial';
end
max_weights=max(weights,[],1);
if max_weights(1)==0
    links=[];
    overlap=0;
    corr_thresh=[];
end

%Assign appropriate probability assignment method
if length(neurons)==2&isequal(probability_assignment_method,'default')
    probability_assignment_method='gmm'
elseif length(neurons)>2&isequal(probability_assignment_method,'default')
    probability_assignment_method='Kmeans'
end

%% Copy neurons and links to new memory locations, standardize FOV size for each session


%Sources2D is mutable, copy a new version, copy a version without trimmed
%neurons
neurons1=neurons;
links1=links;
for i=1:length(neurons)
    neurons1{i}=neurons{i}.copy();
end
clear neurons
neurons=neurons1;
clear neurons1;
for i=1:length(neurons)
    neurons1{i}=neurons{i}.copy();
%     neurons{i}=thresholdNeuron(neurons{i},footprint_threshold); % removed
%     by PV
end
for i=1:length(links)
    links1{i}=links1{i}.copy();
    len=size(links1{i}.C,2);
    ind=find(sum(links1{i}.S(:,1:len/2),2)==0|sum(links1{i}.S(:,len/2+1:end),2)==0);
    links1{i}.delete(ind);
end
clear links
links=links1;
clear links1;
for i=1:length(links)
    links1{i}=links{i}.copy();
%     links{i}=thresholdNeuron(links{i},footprint_threshold); % removed by
%     PV
end
%Normalize FOV for each session
for i=1:length(neurons)
    
    
    max_dims1(i)=neurons{i}.options.d1;  %PV  %% In my case dimensions are equal. I modified the code to avoid changing surce2d unecessarly. 
    max_dims2(i)=neurons{i}.options.d2;  %PV
end
for i=1:length(links)
    max_dims1(end+1)=neurons{i}.options.d1;  %PV
    max_dims2(end+1)=neurons{i}.options.d2;  %PV
end
max_dims1=max(max_dims1);
max_dims2=max(max_dims2);
for i=1:length(neurons)
    curr_dim1=max_dims1-neurons{i}.options.d1;  %PV
    curr_dim2=max_dims2-neurons{i}.options.d2;  %PV
    neurons{i}.A=reshape(neurons{i}.A,neurons{i}.options.d1,neurons{i}.options.d2,[]); %PV
    neurons{i}.A=[neurons{i}.A;zeros(curr_dim1,size(neurons{i}.A,2),size(neurons{i}.A,3))];
    neurons{i}.A=[neurons{i}.A,zeros(size(neurons{i}.A,1),curr_dim2,size(neurons{i}.A,3))];
    neurons{i}.imageSize=[max_dims1,max_dims2];
    neurons{i}.A=reshape(neurons{i}.A,max_dims1*max_dims2,[]);
    try
        neurons{i}.Cn=[neurons{i}.Cn;zeros(curr_dim1,size(neurons{i}.Cn,2))];
        neurons{i}.Cn=[neurons{i}.Cn,zeros(size(neurons{i}.Cn,1),curr_dim2)];
    catch
    end
end
if ~isempty(links)
    for i=1:length(links)
        curr_dim1=max_dims1-neurons{i}.options.d1;  %PV
        curr_dim2=max_dims2-neurons{i}.options.d2;  %PV
        links{i}.A=reshape(links{i}.A,neurons{i}.options.d1,neurons{i}.options.d2,[]);% PV
        links{i}.A=[links{i}.A;zeros(curr_dim1,size(links{i}.A,2),size(links{i}.A,3))];
        links{i}.A=[links{i}.A,zeros(size(links{i}.A,1),curr_dim2,size(links{i}.A,3))];
        links{i}.imageSize=[max_dims1,max_dims2];
        links{i}.A=reshape(links{i}.A,max_dims1*max_dims2,[]);
        try
            links{i}.Cn=[links{i}.Cn;zeros(curr_dim1,size(links{i}.Cn,2))];
            links{i}.Cn=[links{i}.Cn,zeros(size(links{i}.Cn,1),curr_dim2)];
        catch
        end
    end
end


%% Register Sessions (Global)

if register_sessions
    %3 alignment iterations
    for k=1:1 % PV originaly 3
        % %      PV neurons are not correctly registrated!
        k
        o=1:size(neurons,2);
        o(base)=[];
        [neurons(1,o),links]=align_scout_PV(neurons(1,base),neurons(1,o),links);
    end
    %         [neurons,links]=register_neurons_links(neurons,links,registration_template,registration_type,registration_method,base);
    base=randi([1,length(neurons)],1,1);
end
num_rows=ceil(length(neurons)/5);
% figure('Name','Session Alignment')
% 
% for k=1:length(neurons)
%     subplot(num_rows,min(5,length(neurons)),k);
%     imagesc(max(reshape(neurons{k}.A./max(neurons{k}.A,[],1),neurons{k}.imageSize(1),neurons{k}.imageSize(2),[]),[],3))
%     daspect([1,1,1])
%     xticks([])
%     yticks([])
%     title(['Session',num2str(k)])
% end

for i=1:length(neurons)
    neurons{i}.updateCentroid();
end
if ~isempty(links)
    for i=1:length(links)
        links{i}.updateCentroid();
    end
end



%% Construct Distance Metrics Between Sessions 
if ~isempty(links)
    correlation_matrices=construct_correlation_matrix(neurons,links,overlap,max_dist);
else
    for i=1:2*length(neurons)
        correlation_matrices{i}=[];
    end
end


%Insert any new distance metrics below, and add them to the
%distance_metrics cell
%Weights order: correlation, centroid_dist,overlap,JS,SNR,decay



%overlap similarity, now required
overlap_matrices=construct_overlap_matrix(neurons);


%centroid distance (this metric is required, though  the weight may be 0)
distance_matrices=construct_distance_matrix(neurons);





distance_links=cell(1,length(neurons)*2-2);
for i=1:length(neurons)-1
    if ~isempty(links)
        distance_links{2*i-1}=pdist2(neurons{i}.centroid,links{i}.centroid);
        distance_links{2*i}=pdist2(links{i}.centroid,neurons{i+1}.centroid);
        temp=bsxfun(@times, neurons{i}.A, 1./sqrt(sum(neurons{i}.A.^2)));
        temp1=bsxfun(@times,links{i}.A,1./sqrt(sum(links{i}.A.^2)));
        temp2=bsxfun(@times,neurons{i+1}.A,1./sqrt(sum(neurons{i+1}.A.^2)));
        overlap_links{2*i-1}=temp'*temp1;
        overlap_links{2*i}=temp1'*temp2;
        
    else
        distance_links{2*i-1}=[];
        distance_links{2*i}=[];
        overlap_links{2*i-1}=[];
        overlap_links{2*i}=[];
    end
end

%JS distance
if max_weights(4)>0
    JS_matrices=construct_JS_matrix(neurons,max_sess_dist,overlap_matrices);
else
    JS_matrices=cell(length(neurons)-1,length(neurons));
end
if max_weights(5)>0
for i=1:length(neurons)
    neurons{i}.SNR=log(neurons{i}.SNR);
    %neurons{i}.SNR(isoutlier(neurons{i}.SNR))=max(neurons{i}.SNR(setdiff(1:size(neurons{i}.C,1),find(isoutlier(neurons{i}.SNR)))));
    neurons{i}.SNR=(neurons{i}.SNR-mean(neurons{i}.SNR))/std(neurons{i}.SNR);
end
for i=1:length(neurons)
    for j=i:length(neurons)
        %SNR_dist{i,j}=pdist2(neurons{i}.SNR,neurons{j}.SNR)./((repmat(neurons{i}.SNR,1,size(neurons{j}.SNR,1))+repmat(neurons{j}.SNR',size(neurons{i}.SNR,1),1))/2);
        
             
        SNR_dist{i,j}=pdist2(neurons{i}.SNR,neurons{j}.SNR);
    end
end
else
    SNR_dist=cell(length(neurons),length(neurons));
end
if max_weights(6)>0

if isempty(neurons{i}.P.kernel_pars)
    warning('No decay rate available, setting 6th column of weights to 0')
    weights(:,6)=0;
    max_weights(6)=0;
elseif length(neurons{i}.P.kernel_pars)<size(neurons{i}.C,1)&~isempty(neurons{i}.P.kernel_pars)
    neurons{i}.P.kernel_pars(end+1:size(neurons{i}.C,1))=mean(neurons{i}.P.kernel_pars);
    warning('Some missing decay rates, replacing with average')
    
end
end
    
if max_weights(6)>0 

for i=1:length(neurons)
    if isempty(neurons{i}.P.kernel_pars)||size(neurons{i}.C,1)~=length(neurons{i}.P.kernel_pars)
        for l=1:length(neurons)
            neurons{l}=estimate_decay_full(neurons{l});
        end
        break
    end
end     
for i=1:length(neurons)
%     for j=1:length(neurons)
%    for j=i:length(neurons)
%         for k=1:size(neurons{i}.C,1)
%             for l=1:size(neurons{j}.C,1)
%                 decay_dist{i,j}(k,l)=abs(neurons{i}.P.kernel_pars(k)-neurons{j}.P.kernel_pars(l))/(neurons{i}.P.kernel_pars(k)+neurons{j}.P.kernel_pars(l));
%             end
%         end
%    end
    for j=1:length(neurons)
        decay_dist{i,j}=pdist2(neurons{i}.P.kernel_pars,neurons{j}.P.kernel_pars);
        %decay_dist{i,j}=pdist2(decay_rate{i},decay_rate{j});
    end
end
else
    decay_dist=cell(length(neurons),length(neurons));
end


%Add additional metrics to the end of this cell. Make sure distance
%matrices is the first element of the cell, and overlap matrices the second.
for i=1:size(distance_matrices,1)
    for j=1:size(distance_matrices,2)
        distance_metrics{i,j}={distance_matrices{i,j},overlap_matrices{i,j},JS_matrices{i,j},SNR_dist{i,j},decay_dist{i,j}};
        %ind=find(max_weights(4:end)==0);
        %distance_metrics{i,j}(ind+2)=[];
    end
end



% cell of strings 'low', and 'high', indicating whether the distance
% similarity prefers low or high values (centroid distance: low, overlap:
% high) 
% When creating new similarity functions, do not alter any current elements
% of the list, only add terms to the end
similarity_pref={'low','high','low','low','low'};
similarity_id={'centroid','overlap','JS','SNR','decay'};


disp('Beginning Cell Tracking')

%vector of weights for total metrics (including correlation) If no links are used,
%set first elements of this vector to 0.
final_neuron=cell(size(weights,1),length(max_dist),length(min_prob),length(chain_prob));
final_register=cell(size(final_neuron));

for k=1:length(neurons)
    centroids{k}=neurons{k}.centroid;
end
%for jj=1:size(weights,1)
%    for kk=1:length(max_dist)
%        for mm=1:length(min_prob)
%            for nn=1:length(chain_prob)
param_vec=[size(weights,1),length(max_dist),length(min_prob),length(chain_prob)];


max_dist=max_dist;
min_prob=min_prob;
chain_prob=chain_prob;
probability_assignment_method=probability_assignment_method;
max_gap=max_gap;
single_corr=single_corr;
corr_thresh=corr_thresh;
use_spat=use_spat;

binary_corr=binary_corr;
max_sess_dist=max_sess_dist;
scale_factor=scale_factor;
reconstitute=reconstitute;
construct_combined=construct_combined;

%Automatically detects whether one or more parameter value sets is used and
%applies parallel processing accordingly. 
poolobj=gcp;
if prod(param_vec)==1
    M=0;
else
    M=poolobj.NumWorkers;
end

parfor (oo=1:prod(param_vec),M)
%for oo=1:prod(param_vec)
   % for oo=47
[jj,kk,mm,nn]=ind2sub(param_vec,oo);
 
%disp('weights')
curr_weights=weights(jj,:);
%disp('max_dist')
curr_max_dist=max_dist(kk);
%disp('min_prob')
curr_min_prob=min_prob(mm);
%disp('chain_prob')
curr_chain_prob=chain_prob(nn);

curr_weights=curr_weights/sum(curr_weights);
min_num_neighbors=1.5;
%min_num_neighbors=1;

%disp(['Initialization: ', num2str(time), ' seconds'])
%% Construct Cell Register
%tic
%try
[cell_register,aligned_probabilities,reg_prob]=compute_cell_register_cluster(correlation_matrices,distance_links,overlap_links,distance_metrics,...
    similarity_pref,curr_weights,probability_assignment_method,curr_max_dist,max_gap,curr_min_prob,single_corr,corr_thresh,use_spat,min_num_neighbors,...
    curr_chain_prob,binary_corr,max_sess_dist,centroids,scale_factor,reconstitute,similarity_id);
%  catch
%      cell_register=[];
%      aligned_probabilities=[];
%      reg_prob=[];
%      warning('Cell Tracking Failed')
%  end
%time=toc;
%disp(['Tracking: ', num2str(time), ' seconds'])

%Remove neurons below probability threshold
% if ~isempty(reg_prob)
%     rem_ind=aligned_probabilities<curr_chain_prob|reg_prob<curr_chain_prob;
%     %rem_ind=aligned_probabilities<curr_chain_prob;
% else
%     rem_ind=aligned_probabilities<curr_chain_prob;
%     reg_prob=aligned_probabilities;
% end
% temp=mean([aligned_probabilities,reg_prob],2);
% idx=kmeans(temp,2);
% rem_ind=[];
% 
% if min(mean(temp(idx==1,:),1))<max(mean(temp(idx==2,:),1))-.25
%     rem_ind=[rem_ind,find(idx==1)];
% elseif min(mean(temp(idx==2,:),1))<max(mean(temp(idx==1,:),1))-.25
%     rem_ind=[rem_ind,find(idx==2)];
%     
% end





% cell_register(rem_ind,:)=[];
% aligned_probabilities(rem_ind,:)=[];
% reg_prob(rem_ind,:)=[];


%% Construct Neuron Throughout Sessions Using Extracted Registration
if isempty(cell_register)||~construct_combined
    neuron=Sources2D;
else 
if ~isempty(cell_register)
    cell_register=uint32(cell_register);
end
neuron=Sources2D;

total = 0;
start=[];
ends=[];
for k=1:length(neurons)
    start(k)=total+1;
    total = total + size(neurons{k}.C,2); 
    ends(k)=total;
end

neuron.C = zeros(size(cell_register, 1), total);
neuron.C_raw = zeros(size(cell_register, 1), total);
neuron.S = zeros(size(cell_register, 1), total);
neuron.C_df = zeros(size(cell_register, 1), total);
neuron.trace = zeros(size(cell_register,1),total);


%Construct Sources2D object representing neurons over full recording

A_per_session=zeros(size(neurons{1}.A,1),size(cell_register,1),length(neurons));
A=zeros(size(neurons{1}.A,1),size(cell_register,1));
identified=zeros(size(cell_register,1),1);
decays=zeros(size(cell_register,1),1);

for k=1:size(cell_register,2)
    
    
    
    ind = cell_register(:,k)~=0;
    index = find(ind);
    identified=identified+ind;
    if isprop(neurons{k}, 'C') && ~isempty(neurons{k}.C)
       neuron.C(index, start(k):ends(k)) = neurons{k}.C(cell_register(ind,k),:); 
    end
    
    if isprop(neurons{k}, 'C_raw') && ~isempty(neurons{k}.C_raw)
        neuron.C_raw(index, start(k):ends(k)) = neurons{k}.C_raw(cell_register(ind, k),:);
    end
    
    if isprop(neurons{k}, 'C_df') && ~isempty(neurons{k}.C_df)
        neuron.C_df(index, start(k):ends(k)) = neurons{k}.C_df(cell_register(ind, k),:);
    end
    
    if isprop(neurons{k}, 'S') && ~isempty(neurons{k}.S)
        neuron.S(index, start(k):ends(k)) = neurons{k}.S(cell_register(ind, k),:);
    end
    if isprop(neurons{k}, 'trace') && ~isempty(neurons{k}.trace)
        neuron.trace(index, start(k):ends(k)) = neurons{k}.trace(cell_register(ind, k),:);
    end
    
    
    A(:,index)=A(:,index)+neurons{k}.A(:,cell_register(ind,k));
    A_per_session(:,index,k)=neurons{k}.A(:,cell_register(ind,k));
    if isprop(neurons{k}.P,'kernel_pars')
        decays(index)=decays(index)+neurons{k}.P.kernel_pars(cell_register(ind,k));
    end
    
end

neuron.A=A./identified';
neuron.P.kernel_pars=decays./identified;
neuron.A_per_session=A_per_session;


try
    neuron.Cn=neurons{base}.Cn;
end
neuron.imageSize=neurons{base}.imageSize;
neuron.updateCentroid();
try
    neuron=calc_snr(neuron);
end
neuron.connectiveness=aligned_probabilities;
neuron.probabilities=reg_prob;

neuron.cell_register=cell_register;
try
    neuron.options=neurons{1}.options;
end

end
final_register{oo}=uint32(cell_register);
final_neuron{oo}=neuron;
end
        
if length(final_neuron)==1
    neuron=final_neuron{1};
    cell_register=final_register{1};
    ind=find(sum(cell_register==0,2)==0);
%     figure('Name','Identified in All Sessions') PV

%     for k=1:length(neurons)
%         subplot(num_rows,min(5,length(neurons)),k);
%         imagesc(max(reshape(neurons{k}.A(:,cell_register(ind,k))./max(neurons{k}.A(:,cell_register(ind,k)),[],1),neurons{k}.imageSize(1),neurons{k}.imageSize(2),[]),[],3))
%         daspect([1,1,1])
%         xticks([])
%         yticks([])
%         title(['Session',num2str(k)])
%     end

%PV

else
    cell_register=final_register;
    neuron=final_neuron;
end
