function Mr=interpolate_dropped_frames(Mr)

if isa(Mr,'uint8')
    u8=1;
else
    u8=0;
end
dropped=squeeze(mean(mean(Mr)))==0;
if sum(dropped)>0
    fprintf(1, 'There are %1.0f dropped frames  \n',sum(dropped));
    fprintf(1, 'Fixing by interpolation... \n');
    Mr=single(Mr);
    Mr(:,:,dropped)=nan;

    Mr = fillmissing(Mr,'linear',3);

    if u8==1
        Mr=uint8(Mr);
    else
        Mr=uint16(Mr);
    end
else

end