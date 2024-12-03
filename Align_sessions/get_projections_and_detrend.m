function [Y,p,R,opt]=get_projections_and_detrend(Y,opt)
S = class(Y);
[Y,opt.Mask]=remove_borders(Y,0);
M=median(Y,3);
BV=CaliAli_get_blood_vessels(M,opt);
Y=CaliAli_remove_background(Y,opt);
if opt.preprocessing.remove_BV
    Y=remove_BV(Y,BV); %Remove BV from the nueron filtered projections
end

if opt.preprocessing.fastPNR
    [Cn,PNR]=get_PNR_Cn_fast(Y);
else
    [~,Cn,PNR]=get_PNR_coor_greedy_PV(Y,opt.gSig,[],[],opt.preprocessing.neuron_enhance);
end


R=range(Y,'all');
if strcmp(S,'uint8')
    Y=v2uint8(Y);
else
    Y=v2uint16(Y);
end
X=imfuse(mat2gray(Cn),BV,'Scaling','joint','ColorChannels',[1 2 0]);
p={mat2gray(M),BV,Cn,PNR,X};
p = array2table(p,'VariableNames',{'Mean','BloodVessels','Neurons','PNR','BV+Neurons'});
end


function Y=remove_BV(Y,BV)
mask=mat2gray(BV.^2);
mask=(1-double(mask));
mask=mask.^10;
Y=Y.*mask;
end
