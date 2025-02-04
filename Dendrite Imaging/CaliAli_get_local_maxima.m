function v_max=CaliAli_get_local_maxima(CaliAli_options)
gSig=CaliAli_options.preprocessing.gSig;
cn=CaliAli_options.inter_session_alignment.Cn;
pnr=CaliAli_options.inter_session_alignment.PNR;

tmp_d = max(1,round(gSig));
v_max = ordfilt2(cn.*pnr, tmp_d^2, true(tmp_d));
