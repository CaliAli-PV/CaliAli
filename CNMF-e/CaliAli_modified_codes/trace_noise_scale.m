function out = trace_noise_scale(neuron, action, varargin)
%TRACE_NOISE_SCALE  Record and undo the gain applied by scale_to_noise.
%
%   scale_to_noise divides every trace by its own noise level, per component and
%   per session, so a finished extraction stores traces in NOISE UNITS. The
%   deconvolution downstream depends on that: postprocessDeconvolvedTraces
%   applies an absolute amplitude threshold and only works if a trace's noise is
%   1. So the traces must stay as they are.
%
%   A residual, though, is Y - A*C - background, and Y is the movie. Pairing
%   noise-unit traces with the movie subtracts a model roughly six times too
%   large, which leaves more variance than it removes and makes every residual
%   image look like the raw data. That is why residual seeding placed most of
%   its components where there is no neuron.
%
%   This keeps the gain that was divided out, so it can be multiplied back at
%   the point a residual is built, without touching what is stored.
%
%   USAGE
%     neuron = trace_noise_scale(neuron, 'record', ranges, sn)
%         Store SN, one row per component and one column per frame range, keyed
%         by the component ids as they stand now. RANGES is nB-by-2. Any factor
%         already stored for those frames is MULTIPLIED IN, not replaced: the
%         scaling can be applied more than once -- an extraction that is
%         propagated onto more sessions and finished again is scaled twice --
%         and the stored number has to be the whole gain back to movie units.
%         The second pass sees traces whose noise is already 1, so its own
%         factor is near 1 and replacing would silently throw the real gain
%         away.
%
%     C = trace_noise_scale(neuron, 'apply', C)
%         Return C in movie units. Components with no stored factor are left
%         alone, which is correct for components created after the scaling and
%         for extractions saved before this was recorded.
%
%     tf = trace_noise_scale(neuron, 'has')
%         Whether any factor is stored.
%
%     neuron = trace_noise_scale(neuron, 'clear')
%         Forget the stored gain. Call this whenever ALL traces are
%         re-estimated from the movie, because they are then in movie units
%         again and the recorded gain no longer describes them.
%
%     neuron = trace_noise_scale(neuron, 'reset', idx)
%         Set the gain of components IDX to 1, leaving the rest. For a partial
%         update, where only some traces were re-estimated.
%
%   The linear detrend that scale_to_noise also applies is NOT undone; only the
%   gain is. The gain is the part that spans an order of magnitude.
%
%   Author: Pablo Vergara

switch lower(action)
    case 'record'
        ranges = varargin{1};
        sn = varargin{2};
        sn(~isfinite(sn) | sn <= 0) = 1;
        K = size(sn, 1);
        % ids can be shorter than the component count: update_residual_custom_seeds
        % appends components without extending them. Pad so every row has a key,
        % using ids that cannot collide with real ones.
        ids = neuron.ids(:)';
        if numel(ids) < K
            ids = [ids, max([ids, 0]) + (1:(K - numel(ids)))];
        elseif numel(ids) > K
            ids = ids(1:K);
        end
        prev = stored(neuron);
        if ~isempty(prev)
            % Compose with what is already there. Factors are constant within a
            % range, so each new range takes the existing factor covering its
            % first frame.
            [tf, loc] = ismember(ids, prev.ids);
            for b = 1:size(ranges, 1)
                pb = find(prev.ranges(:,1) <= ranges(b,1) & ...
                          prev.ranges(:,2) >= ranges(b,1), 1);
                if isempty(pb), continue; end
                g = ones(K, 1);
                g(tf) = prev.sn(loc(tf), pb);
                g(~isfinite(g) | g <= 0) = 1;
                sn(:, b) = sn(:, b) .* g;
            end
        end
        s = struct('ids', ids, 'ranges', ranges, 'sn', sn);
        opts = neuron.CaliAli_options;
        opts.cnmf.trace_noise_scale = s;
        neuron.CaliAli_options = opts;
        out = neuron;

    case 'has'
        out = ~isempty(stored(neuron));

    case 'clear'
        opts = neuron.CaliAli_options;
        opts.cnmf.trace_noise_scale = [];
        neuron.CaliAli_options = opts;
        out = neuron;

    case 'reset'
        idx = varargin{1};
        s = stored(neuron);
        out = neuron;
        if isempty(s) || isempty(idx), return; end
        cur = neuron.ids(:)';
        if numel(cur) >= max(idx)
            [tf, loc] = ismember(cur(idx), s.ids);
            s.sn(loc(tf), :) = 1;
            opts = neuron.CaliAli_options;
            opts.cnmf.trace_noise_scale = s;
            neuron.CaliAli_options = opts;
            out = neuron;
        end

    case 'apply'
        C = varargin{1};
        s = stored(neuron);
        if isempty(s) || isempty(C)
            out = C;
            return
        end
        % Map stored rows onto the components as they stand now. Merging,
        % removal and reordering all change position but not id.
        K = size(C, 1);
        cur = neuron.ids(:)';
        if numel(cur) < K
            cur = [cur, nan(1, K - numel(cur))];   % unknown: no factor applied
        elseif numel(cur) > K
            cur = cur(1:K);
        end
        [tf, loc] = ismember(cur, s.ids);
        out = C;
        T = size(C, 2);
        for b = 1:size(s.ranges, 1)
            f1 = max(1, s.ranges(b, 1));
            f2 = min(T, s.ranges(b, 2));
            if f2 < f1, continue; end
            g = ones(K, 1);
            g(tf) = s.sn(loc(tf), b);
            g(~isfinite(g) | g <= 0) = 1;
            out(:, f1:f2) = C(:, f1:f2) .* g;
        end

    otherwise
        error('trace_noise_scale:action', ...
            'action must be ''record'', ''apply'' or ''has'', got ''%s''.', action);
end
end


function s = stored(neuron)
s = [];
try
    v = neuron.CaliAli_options.cnmf.trace_noise_scale;
    if isstruct(v) && ~isempty(v) && isfield(v, 'sn') && ~isempty(v.sn)
        s = v;
    end
catch
end
end
