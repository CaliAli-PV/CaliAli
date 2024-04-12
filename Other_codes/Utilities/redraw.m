function redraw(frame,c,V)
imshow(V(:,:,frame),c)
end

% videofig(36000, @(frm,c) redraw(frm,c,V));