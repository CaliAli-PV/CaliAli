function out=plot_energy_PV(IM,e)
% out=plot_energy_PV(IM,E)
IM=flip(IM);
e=flip(e);

cmap=v2uint8([zeros(256,1),(1:256)',zeros(256,1)]);
for i=1:size(IM,2)
    E=e{1,i};
    E=mat2gray(E);
    E(size(IM{1, i},2)+1:end)=[];
    if i==3;
        cmap=v2uint8([(1:256)',(1:256)',zeros(256,1)]);
    end
    if i==4;
        cmap=v2uint8([(1:256)',zeros(256,1),zeros(256,1)]);
    end
    Fr=[];
for k=progress(1:size(IM{1, i},2))
    fig=figure('position',[968.2  286.6 847.2 466.4],'visible','off');
    tiledlayout(2,4,"TileSpacing","compact");
    nexttile([1,2])
    lim=IM{1, i}{7, k};
    imshow(v2uint8(IM{1, i}{1,k}(lim(1,1):lim(2,1),lim(1,2):lim(2,2))));
    colormap(cmap);
    title("Session 1");

    %===================
    nexttile([1,2])
    lim=IM{1, i}{7, k};
    imshow(v2uint8(IM{1, i}{3,k}(lim(1,1):lim(2,1),lim(1,2):lim(2,2))));
    colormap(cmap);
    title("Session 2 Warped")
    %===================
    nexttile([1,2])
    showgrid_PV(IM{1, i}{5,k}*10,IM{1, i}{6,k}*10,4,lim)
    title("Displacement grid")
    %===================
    nexttile([1,2])
    plot(1:k,E(1:k),'r');
    ylim([0 1])
    xlim([1 length(E)])
    title("Scaled Energy")
    xlabel("Iteration")
    ylabel("E")
    plot_darkmode
    temp= getframe(fig);
    Fr(:,:,:,k)=temp.cdata;
    close all;
end
out{i}=Fr;
end
