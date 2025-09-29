function [varargout, log] = run_and_monitor_mem(fn, nout, sample_hz)
% Run a function handle while monitoring RAM usage (esp. macOS).
% Usage:
%   [out1,out2,log] = run_and_monitor_mem(@() myfunc(a,b), 2, 5);
%   plot(log.t, log.usedMB); xlabel('s'); ylabel('Used MB');

if nargin<2, nout = 0; end
if nargin<3, sample_hz = 4; end
assert(isa(fn,'function_handle'), 'fn must be a function handle');

log.t = []; log.freeMB = []; log.usedMB = []; log.totalMB = [];
log.platform = computer; log.error = [];

% --- platform helpers
if ismac
    totalMB = mac_total_mem_mb();
    free_fun = @mac_free_memory_mb;
elseif ispc
    totalMB = [];
    free_fun = @win_free_memory_mb;
else
    totalMB = linux_total_mem_mb();
    free_fun = @linux_free_memory_mb;
end

% --- sampler (nested, captures log)
t0 = tic;
function sample(~,~)
    fmb = free_fun();
    if isempty(totalMB)
        tmb = linux_total_mem_mb(); % Windows: infer total each time not needed; we build "used" differently
        umb = tmb - fmb;
        total_now = tmb;
    elseif ispc
        % Windows: free_fun() returns [freeMB,totalMB,usedMB]
        [fmb_win, tmb_win, umb_win] = free_fun();
        fmb = fmb_win; umb = umb_win; total_now = tmb_win;
    else
        umb = totalMB - fmb; total_now = totalMB;
    end
    log.t(end+1,1) = toc(t0);
    log.freeMB(end+1,1) = fmb;
    log.usedMB(end+1,1) = umb;
    log.totalMB(end+1,1) = total_now;
end

tmr = timer('ExecutionMode','fixedSpacing', 'Period', 1/max(sample_hz,0.1), ...
            'TimerFcn', @sample, 'ErrorFcn', @(~,e) disp(e.Data));

% --- run
try
    start(tmr);
    if nout>0
        [varargout{1:nout}] = fn();
    else
        fn();
    end
catch e
    log.error = e;
    rethrow(e);
end
stop(tmr); delete(tmr);

% --- final sample (ensure last point)
sample();

% --- summary
log.peakUsedMB = max(log.usedMB);
log.minFreeMB  = min(log.freeMB);
end

% ===== macOS helpers =====
function mb = mac_total_mem_mb()
[st,out] = system('sysctl -n hw.memsize');
assert(st==0, 'sysctl failed');
mb = str2double(strtrim(out)) / (1024^2);
end

function mb = mac_free_memory_mb()
% free + inactive + speculative (closer to "available")
[st,out] = system('vm_stat');
assert(st==0, 'vm_stat failed');
pgsz = regexp(out, 'page size of (\d+) bytes', 'tokens','once');
if isempty(pgsz), pgsz = {'4096'}; end
pgsz = str2double(pgsz{1});
val = @(name) str2double(regexprep(regexp(out, [name ':\s+(\d+).*$'], 'tokens','once'), '\.', ''));
free = val('Pages free'); inact = val('Pages inactive'); spec = val('Pages speculative');
mb = (free + inact + spec) * pgsz / (1024^2);
end

% ===== Windows helpers =====
function [freeMB, totalMB, usedMB] = win_free_memory_mb()
[us, sys] = memory; %#ok<ASGLU>
freeMB  = sys.PhysicalMemory.Available / (1024^2);
totalMB = sys.PhysicalMemory.Total     / (1024^2);
usedMB  = totalMB - freeMB;
end

% ===== Linux helpers =====
function mb = linux_total_mem_mb()
[st,out] = system('awk ''/MemTotal/ {print $2}'' /proc/meminfo');
assert(st==0, 'MemTotal read failed');
mb = str2double(strtrim(out)) / 1024;
end

function mb = linux_free_memory_mb()
[st,out] = system('awk ''/MemAvailable/ {print $2}'' /proc/meminfo');
assert(st==0, 'MemAvailable read failed');
mb = str2double(strtrim(out)) / 1024;
end