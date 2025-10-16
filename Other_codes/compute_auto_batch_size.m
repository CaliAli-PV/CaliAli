function [batch_sz, total_system_memory_GB] = compute_auto_batch_size(batch_sz,filename,d)
isAuto = (ischar(batch_sz) || isstring(batch_sz)) && strcmp(batch_sz, 'auto');
total_system_memory_GB=0;
if isAuto
    if ~exist("d","var")
        f=h5info(filename);
        d=f.Datasets.Dataspace.Size(1:2);
    end

    try
        [total_system_memory_GB,~] = getSystemMemory;
    catch
        cprintf('*red','Total physical memory could not be determined.\n');
        cprintf('red','Avilable memory was set to 18GB by default.\n');
        total_system_memory_GB = 18;
    end

    if total_system_memory_GB <= 8
        cprintf('*red','Detected %.1f GB RAM. CaliAli recommends at least 16 GB for automatic batch sizing.\n', total_system_memory_GB);
    end
    batch_sz = floor((total_system_memory_GB*2*10^7)/(d(1)*d(2))/100)*100;
    cprintf('-comment','Automatically set batch size to %d frames based on %.1f GB RAM and (%dx%d ) frame size.\n', ...
        batch_sz, total_system_memory_GB,d(1),d(2));
end

end