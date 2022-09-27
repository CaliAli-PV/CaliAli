function [C,S]=deconv_PV(C_raw,opts);

   parfor i=1:size(C_raw,1)
    [C(i,:),S(i,:)]=deconvolveCa(C_raw(i,:),opts);
    end