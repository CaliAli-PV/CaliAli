function [totalMemGB, freeMemGB] = getSystemMemory()
%% getSystemMemory: Total and available RAM, in GiB.
%
% One branch per platform, because there is no portable way to ask. Windows has
% MATLAB's own memory function; macOS and Linux are read by shelling out to
% sysctl, vm_stat and /proc/meminfo.
%
% IT MUST THROW WHEN IT CANNOT TELL, which is what the validation at the bottom
% is for. Every caller already wraps this in try/catch and substitutes a default
% -- compute_auto_batch_size falls back to 18 GB, CNMFE_parameters to 120 -- but
% a failed probe did not raise anything. str2double of an unmatched regexp is
% NaN, so the function returned NaN and an empty free value, every catch block
% was skipped, and batch_sz = 'auto' came out as NaN frames. A silently wrong
% number is worse than an error the callers are already prepared for.
%
% Outputs:
%   totalMemGB - total physical memory, GiB
%   freeMemGB  - memory currently available, GiB
%
% Author: Pablo Vergara

if ispc  % Windows
    % Retrieve memory details (Windows only)
    m = memory;

    % Convert the values from bytes to GiB (1 GiB = 1024^3 bytes)
    totalMemGB = m.MaxPossibleArrayBytes/ (1024^3);
    freeMemGB  = m.MemAvailableAllArrays  / (1024^3);

elseif ismac  % macOS
    % Get total system memory in bytes
    [~, totalMem] = system('sysctl -n hw.memsize');
    totalMemGB = str2double(totalMem) / (1024^3); % Convert bytes to GiB

    % Get virtual memory statistics
    [~, freeMem] = system('vm_stat');

    % Extract free pages from vm_stat
    freePages = regexp(freeMem, 'Pages free:\s+(\d+)', 'tokens', 'once');
    freePages = str2double(freePages);

    % Extract speculative pages from vm_stat
    speculativePages = regexp(freeMem, 'Pages speculative:\s+(\d+)', 'tokens', 'once');
    speculativePages = str2double(speculativePages);

    % Get the page size (usually 4096 bytes)
    [~, pageSizeResult] = system('sysctl -n hw.pagesize');
    pageSize = str2double(pageSizeResult);

    % Compute free memory in GiB (including speculative pages)
    freeMemGB = ((freePages + speculativePages) * pageSize) / (1024^3);

elseif isunix  % Linux
    [~, totalMem] = system('grep MemTotal /proc/meminfo');
    [~, freeMem] = system('grep MemAvailable /proc/meminfo');

    % Extract numeric values from the output
    totalMem = regexp(totalMem, 'MemTotal:\s+(\d+)', 'tokens', 'once');
    freeMem = regexp(freeMem, 'MemAvailable:\s+(\d+)', 'tokens', 'once');

    % Convert from KB to GiB
    totalMemGB = str2double(totalMem) / (1024^2); % Convert KB to GiB
    freeMemGB = str2double(freeMem) / (1024^2); % Convert KB to GiB
else
    error('CaliAli:getSystemMemory:unsupportedOS', ...
        'Unsupported operating system: %s.', computer);
end

% The probe ran, but did it answer? A tool that is missing, or whose output
% format has changed, leaves these NaN or empty rather than failing outright.
if ~isscalar(totalMemGB) || ~isfinite(totalMemGB) || totalMemGB <= 0 || ...
        ~isscalar(freeMemGB) || ~isfinite(freeMemGB) || freeMemGB < 0
    error('CaliAli:getSystemMemory:probeFailed', ...
        ['Could not read the system memory on %s: got total=%s, free=%s. ' ...
         'The tool this platform is read with is missing or its output format ' ...
         'changed.'], computer, mat2str(totalMemGB), mat2str(freeMemGB));
end
end
