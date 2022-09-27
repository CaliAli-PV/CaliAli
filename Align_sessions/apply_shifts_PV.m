function out=apply_shifts_PV(Vid,shifts);
for k=1:size(Vid,2)
    temp_v=Vid{1,k};
    temp_s=shifts(:,:,:,k);
    parfor i=1:size(temp_v,3)
        temp_v(:,:,i)=imwarp(temp_v(:,:,i)+1,temp_s,'FillValues',1);
    end   
    Vid{1,k}=temp_v;
end
out=cat(3,Vid{:});

end
