function [C,S,Kp]=deconv_PV(C_raw,opts)

parfor i=1:size(C_raw,1)
    [C(i,:),S(i,:),options]=deconvolveCa(C_raw(i,:),opts);
    Kp(i,:)=options.pars;
end