function out = mat_data_cache(action, key, value)
%% mat_data_cache: Hold the patched data in memory without touching the base workspace.
%
% The patched .mat is kept in memory for the whole extraction, because reading
% every patch from disk on every iteration is far slower. That cache used to be
% a variable called mat_data_<hash> created in the BASE workspace with
% evalin('base', '<name>=load(...)'). That had two costs. It put several
% gigabytes into the user's own workspace, where it appeared in their variable
% browser and survived the run. And clearing it again meant clearing the base
% workspace, which is not this pipeline's to clear -- the previous guard,
% clearvars -except parin theFiles, deleted everything else the user had.
%
% A persistent variable gives the same cache with the same lifetime, invisible
% to the user. On a parallel worker it is per-worker, exactly as the base
% workspace was.
%
% Usage:
%   mat_data_cache('set', key, data)   store
%   tf   = mat_data_cache('has', key)  is it there
%   data = mat_data_cache('get', key)  retrieve, [] when absent
%   mat_data_cache('clear', key)       drop one entry
%   mat_data_cache('clear')            drop everything and release the memory
%
% Author: Pablo Vergara

persistent store
if isempty(store)
    store = containers.Map('KeyType', 'char', 'ValueType', 'any');
end

% OUT is assigned only by the actions that produce a value. Assigning it
% unconditionally would mean that calling this as a statement, which is how
% 'set' and 'clear' are used, leaves an ans behind in the caller's workspace.
switch lower(action)
    case 'has'
        out = isKey(store, key);
    case 'get'
        out = [];
        if isKey(store, key), out = store(key); end
    case 'set'
        store(key) = value;
    case 'clear'
        if nargin < 2 || isempty(key)
            store = containers.Map('KeyType', 'char', 'ValueType', 'any');
        elseif isKey(store, key)
            remove(store, key);
        end
    otherwise
        error('CaliAli:matDataCache:badAction', ...
            'Unknown action "%s". Use has, get, set or clear.', action);
end
end
