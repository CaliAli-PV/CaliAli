function [totalMemGB, freeMemGB] = getSystemMemory()
if ispc  % Windows
    % Retrieve memory details (Windows only)
    m = memory;

    % Convert the values from bytes to GiB (1 GiB = 1024^3 bytes)
    totalMemGB = m.PhysicalMemory.Total / (1024^3);
    freeMemGB  = m.PhysicalMemory.Available / (1024^3);

    % Display results
    fprintf('Total Physical Memory: %.2f GiB\n', totalMemGB);
    fprintf('Available Physical Memory: %.2f GiB\n', freeMemGB);

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
    error('Unsupported operating system');
end
end