function [Vid,p,R,opt]=get_projections_and_detrend(Vid,opt)
S = class(Vid);
[Vid,opt.Mask]=remove_borders(Vid,0);
M=median(Vid,3);
BV=CaliAli_get_blood_vessels(M,opt);
Vid=CaliAli_remove_background(Vid,opt);
[~,Cn,PNR]=get_PNR_coor_greedy_PV(Vid,opt.gSig,[],[],opt.preprocessing.neuron_enhance);
R=range(Vid,'all');
if strcmp(S,'uint8')
    Vid=v2uint8(Vid);
else
    Vid=v2uint16(Vid);
end
X=imfuse(mat2gray(Cn),BV,'Scaling','joint','ColorChannels',[1 2 0]);
p={mat2gray(M),BV,Cn,PNR,X};
p = array2table(p,'VariableNames',{'Mean','BloodVessels','Neurons','PNR','BV+Neurons'});
end

