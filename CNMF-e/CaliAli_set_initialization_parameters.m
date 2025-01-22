function CaliAli_set_initialization_parameters(CaliAli_options)

if strcmp(CaliAli_options.preprocessing.structure,'dendrite')
    CNMFe_app_dendrite;
else
    CNMFe_app;
end