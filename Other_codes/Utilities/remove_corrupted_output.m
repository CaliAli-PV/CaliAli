function removed = remove_corrupted_output(thefiles)
% remove_corrupted_output: delete pre-allocated output files that contain data

for k=1:length(thefiles)
    output_file=thefiles{k};
    removed = false;

    if ~isfile(output_file)
        return;
    end

    try
        m = matfile(output_file);
        info = whos(m, 'Y');
        if isempty(info) || numel(info.size) < 3 || info.size(3) < 1
            return;
        end
        last_idx = info.size(3);
        slice = m.Y(:,:,last_idx);
        if ~any(slice(:))
            delete(output_file);
            removed = true;
        end
    catch
        delete(output_file);
        removed = true;
    end
end
end


