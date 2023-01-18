function plot_spatial_opto(T,opt)

%% 5,6,6 are representative recordings 
h=[5,6,6];
figure;tiledlayout(1,3);
for m=1:3
    d=T.(m)(h(m),1).d;
    a=T.(m)(h(m),1).a;
    a=a./max(a,[],1);
    s=T.(m)(h(m),1).s;

    nexttile
    thr=0;

    s1=full(mean(s(:,1:length(opt{1, 1}))>thr,2)>0);
    s2=full(mean(s(:,1+length(opt{1, 1}):end)>thr,2)>0);

    r=reshape(a*double(s1&~s2),d);
    g=reshape(a*double(s1&s2),d);
    b=reshape(a*double(~s1&s2),d);


    Im=cat(3,r,g,b);
    imshow(Im)
    plot_boundries(a,d);
end
end


function plot_boundries(a,d)
hold on;
for i=1:size(a,2)
im=reshape(a(:,i),d);
[B,L] = bwboundaries(mat2gray(im)>0.05);
boundary=B{1, 1};
plot(boundary(:,2), boundary(:,1),'Color',[1 1 1], 'LineWidth', 0.2)
end

end

