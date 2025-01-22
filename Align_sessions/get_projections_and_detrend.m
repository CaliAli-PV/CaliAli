function [Y,p,R,CaliAli_options]=get_projections_and_detrend(Y,CaliAli_options)
S = class(Y);
[Y,CaliAli_options.Mask]=remove_borders(Y,0);
M=median(Y,3);
BV=CaliAli_get_blood_vessels(M,CaliAli_options);
Y=CaliAli_remove_background(Y,CaliAli_options);
if CaliAli_options.preprocessing.remove_BV
    Y=remove_BV(Y,BV); %Remove BV from the nueron filtered projections
end

if strcmp(CaliAli_options.preprocessing.structure,'dendrite')
    [Cn,PNR]=get_PNR_Cn_dendrite(Y,CaliAli_options);
elseif CaliAli_options.preprocessing.fastPNR
    [Cn,PNR]=get_PNR_Cn_fast(Y);
else
    [~,Cn,PNR]=get_PNR_coor_greedy_PV(Y,CaliAli_options.gSig,[],[],CaliAli_options.preprocessing.neuron_enhance);
end


if ~isempty(CaliAli_options.preprocessing.median_filtering)
    Cn=medfilt2(Cn,CaliAli_options.preprocessing.median_filtering);
    PNR=medfilt2(PNR,CaliAli_options.preprocessing.median_filtering);
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
Y=double(Y).*mask;
end
