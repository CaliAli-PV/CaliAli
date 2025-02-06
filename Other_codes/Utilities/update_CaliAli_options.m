function update_CaliAli_options()


input_files = uipickfiles('FilterSpec','*.mat');

for i=1:length(input_files)
    CaliAli_options=CaliAli_load(input_files{i}(:),'CaliAli_options');
    CaliAli_options=CaliAli_parameters(CaliAli_options);
    CaliAli_save(input_files{i}(:),CaliAli_options)
end