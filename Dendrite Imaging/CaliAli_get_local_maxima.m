function v_max=CaliAli_get_local_maxima(CaliAli_options)

gSig=CaliAli_options.preprocessing.gSig;
cn=CaliAli_options.inter_session_alignment.Cn;
pnr=CaliAli_options.inter_session_alignment.PNR;

if length(gSig)>1
    theta=90-CaliAli_options.preprocessing.dendrite_theta/2:5:90+CaliAli_options.preprocessing.dendrite_theta/2;
    v_max = find_local_maxima_elongated(cn.*pnr,theta,gSig);
else
    tmp_d = max(1,round(gSig));
    v_max = ordfilt2(cn.*pnr, tmp_d^2, true(tmp_d));
end