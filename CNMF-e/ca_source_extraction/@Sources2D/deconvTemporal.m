function C_ = deconvTemporal(obj, use_parallel, method_noise, ind_update)
if ~exist('use_parallel', 'var')||isempty(use_parallel)
    use_parallel = true;
end
if ~exist('method_noise', 'var') || isempty(method_noise)
    method_noise = 'psd';
end
C_raw_all = obj.C_raw;
K = size(C_raw_all, 1);
if K==0
    fprintf('Your got 0 neurons! there is no need for deconvolving temproal traces.\n');
    C_ = [];
    return;
end
if ~exist('ind_update', 'var') || isempty(ind_update)
    ind_update = 1:K;
else
    ind_update = unique(ind_update(:))';
    if any(ind_update < 1) || any(ind_update > K)
        error('ind_update contains indices outside the valid range 1:%d.', K);
    end
end
if isempty(ind_update)
    C_ = obj.C;
    return;
end

C_raw_ = C_raw_all(ind_update, :);
K_update = size(C_raw_, 1);
C_raw_ = mat2cell(C_raw_, ones(K_update,1), size(C_raw_,2));
C_ = cell(K_update,1);
S_ = C_;
kernel_pars = cell(K_update, 1);
sn = cell(K_update,1);
num_per_row = 100;
for m=1:K_update
    fprintf('|');
    if mod(m, num_per_row)==0
        fprintf('\n');
    end
end
fprintf('\n');
deconv_options = obj.options.deconv_options;
if use_parallel
    tmp_flag = false(K_update,1);
    ind = randi(K_update, ceil(K_update/num_per_row), 1);
    tmp_flag(ind) = true;
    tmp_flag = num2cell(tmp_flag);
    parfor k=1:size(C_raw_,1)  
        ck_raw = C_raw_{k};
        
        if any(isnan(ck_raw))
            C_{k} = zeros(size(ck_raw));
            S_{k} = zeros(size(ck_raw));
            C_raw_{k} = zeros(size(ck_raw));
        else
            if strcmpi(method_noise, 'histogram')
                [~, tmp_sn] = estimate_baseline_noise(ck_raw);
            else
                tmp_sn = GetSn(ck_raw);
            end
            % subtract the baseline
            sn{k} = tmp_sn;
            
            % deconvolution
            [ck, sk, tmp_options]= deconvolveCa(ck_raw,deconv_options, 'sn', tmp_sn);
            
            if sum(abs(ck))==0
                ck = ck_raw;
            end
            C_{k} = reshape(ck, 1, []);
            S_{k} = reshape(sk, 1, []);
            kernel_pars{k} = reshape(tmp_options.pars, 1, []);
            C_raw_{k} = ck_raw - tmp_options.b;
        end
        fprintf('.');
        if tmp_flag{k}
            fprintf('\n');
        end
    end
else
    for k=1:size(C_raw_,1)
        ck_raw = C_raw_{k};
        if any(isnan(ck_raw))
            C_{k} = zeros(size(ck_raw));
            S_{k} = zeros(size(ck_raw));
            C_raw_{k} = zeros(size(ck_raw));
        else
            if strcmpi(method_noise, 'histogram')
                [~, tmp_sn] = estimate_baseline_noise(ck_raw);
            else
                tmp_sn = GetSn(ck_raw);
            end
            % subtract the baseline
            sn{k} = tmp_sn;
            
            % deconvolution
            [ck, sk, tmp_options]= deconvolveCa(ck_raw, deconv_options, 'sn', tmp_sn);
            
            if sum(abs(ck))==0
                ck = ck_raw;
            end
            C_{k} = reshape(ck, 1, []);
            S_{k} = reshape(sk, 1, []);
            kernel_pars{k} = reshape(tmp_options.pars, 1, []);
            C_raw_{k} = ck_raw - tmp_options.b;
        end
        fprintf('.');
        if mod(k,num_per_row)==0
            fprintf('\n');
        end
    end
end
fprintf('\n');
C_update = cell2mat(C_);
C_raw_update = cell2mat(C_raw_);
S_update = cell2mat(S_);

if numel(ind_update) == K
    obj.C = C_update;
    obj.C_raw = C_raw_update;
    obj.S = S_update;
    obj.P.kernel_pars = cell2mat(kernel_pars);
    obj.P.neuron_sn = cell2mat(sn);
    C_ = obj.C;
    return;
end

C_full = obj.C;
if isempty(C_full) || ~isequal(size(C_full), size(C_raw_all))
    C_full = zeros(size(C_raw_all));
end
C_raw_full = C_raw_all;
S_full = obj.S;
if isempty(S_full) || ~isequal(size(S_full), size(C_raw_all))
    S_full = zeros(size(C_raw_all));
end

C_full(ind_update, :) = C_update;
C_raw_full(ind_update, :) = C_raw_update;
S_full(ind_update, :) = S_update;
obj.C = C_full;
obj.C_raw = C_raw_full;
obj.S = S_full;

kernel_update = cell2mat(kernel_pars);
if isfield(obj.P, 'kernel_pars') && ~isempty(obj.P.kernel_pars) && ...
        size(obj.P.kernel_pars, 1)==K && size(obj.P.kernel_pars, 2)==size(kernel_update, 2)
    kernel_full = obj.P.kernel_pars;
else
    kernel_full = zeros(K, size(kernel_update, 2));
end
kernel_full(ind_update, :) = kernel_update;
obj.P.kernel_pars = kernel_full;

sn_update = cell2mat(sn);
if isfield(obj.P, 'neuron_sn') && ~isempty(obj.P.neuron_sn) && numel(obj.P.neuron_sn)==K
    sn_full = obj.P.neuron_sn(:);
else
    sn_full = zeros(K, 1);
end
sn_full(ind_update) = sn_update(:);
obj.P.neuron_sn = sn_full;
C_ = obj.C;
end
