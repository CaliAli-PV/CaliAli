function plot_spatial(T)
% plot_spatial(out)
%% 5,6,6 are representative recordings
ses_len=1500;
lab=T.Properties.VariableNames;
figure;tiledlayout(size(T,2),size(T,1),'TileSpacing','none');

C = table2cell(T);
co=distinguishable_colors(ceil(size(C{1}.c,2)./ses_len),'k');
d=C{1}.d;
for m=1:numel(C)
    a=C{m}.a;
    a=a./max(a,[],1);
    c=C{m}.m(:,2);
%     c=mean_c(c,co);
    nexttile

    r=reshape(max(a,[],2),d);
    g=reshape(max(a.*c',[],2),d);
    b=reshape(max(a.*c',[],2),d);
    Im=cat(3,r,g,b);
    imagesc(Im)
    axis off;
%     plot_boundries(a,d);
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


function Ac=mean_c(c,co);
ses_len=round(size(c,2)/size(co,1));
k=0;
for i=1:size(co,1)
    Ac(:,i)=mean(c(:,k+1:k+ses_len),2);
    k=k+ses_len;
end
Ac=Ac./max(Ac,[],2);
end




