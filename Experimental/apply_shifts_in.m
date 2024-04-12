function Vid=apply_shifts_in(Vid,shifts);
for k=1:length(Vid)
    temp_v=Vid{k};
    temp_s=shifts(:,:,:,k);
    parfor i=1:size(temp_v,3)
        temp_v(:,:,i)=imwarp(temp_v(:,:,i),temp_s,'FillValues',0);
    end   
    Vid{k}=temp_v;
end

end