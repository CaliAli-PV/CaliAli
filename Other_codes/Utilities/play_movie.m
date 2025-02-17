function Mov=play_movie(neuron,thr,batch_num)
% Function to display results of calcium imaging analysis
% This function plays a movie of neuronal activity, reconstructing
% the background and subtracting neuron signals.
%
% Inputs:
%   neuron    - Structure containing neuron data
%   batch_num - (Optional) Batch number of data to load (default: 1)

% Set default batch number if not provided
if ~exist("batch_num","var")
    batch_num=1;
end
neuron=CNMF_CaliAli_update('Temporal',neuron);
% Extract spatial dimensions from neuron options
d1=neuron.options.d1;
d2=neuron.options.d2;

% Compute frame indices for the selected batch
fn=[0,cumsum(get_batch_size(neuron))];

% Load the corresponding batch of imaging data
Y = neuron.load_patch_data([],[fn(batch_num)+1,fn(batch_num+1)]);

% Convert 3D movie data into a 2D matrix if necessary
if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end

% Replace NaN values with zeros to avoid artifacts
Y(isnan(Y)) = 0;

%% Subtract neuronal activity from raw data
% Retrieve spatial components of neurons
A=full(neuron.A);
Y=single(Y); % Convert data type to single precision for efficiency

% Compute the neuronal signal from calcium traces
C=neuron.C_raw(:,fn(batch_num)+1:fn(batch_num+1));
ns=single(A*C);

% Reconstruct and reshape background signal
bg=single(reshape(reconstruct_background_residual(neuron,[fn(batch_num)+1,fn(batch_num+1)]), [], size(Y,2)));

% Compute the residual signal (raw - neuronal - background)
res=Y-ns-bg;

% 3reshape stuff
Y=reshape(Y,d1,d2,[]);
ns=reshape(ns,d1,d2,[]);
% bg=reshape(bg,d1,d2,[]);
res=reshape(res,d1,d2,[]);

% Display the concatenated results using implay
% Order: Raw data | Background
%         Neuronal signal | Residual signal

% tmp = mod((1:K)', 6)+1;
Y_mixed = zeros(d1*d2,size(C,2));
temp = prism;
% temp = bsxfun(@times, temp, 1./sum(temp,2));
col = temp(randi(64, size(A,2),1), :);
for m=1:3
    Y_mixed(:, :, m) = A* (diag(col(:,m))*C);
end
if ~exist('thr','var')
    thr=[0,256];
end
Y_mixed=v2uint8(permute(reshape(Y_mixed,d1,d2,[],3),[1,2,4,3]),thr);


Mov=v2uint8(cat(2,gray2rgb(Y,'hot',thr),Y_mixed,gray2rgb(res,'hot',thr)));
implay(Mov);
end