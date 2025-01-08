function CNMFe_batch()


input_files = uipickfiles('FilterSpec','*_ds*.mat');


for i=1:size(input_files,1)
    try
        temp=input_files{i};
        CaliAli_options=CaliAli_load(temp,'CaliAli_options');
        if strcmp(CaliAli_options.preprocessing.structure,'neuron')
            runCNMFe(temp);
        elseif strcmp(CaliAli_options.preprocessing.structure,'dendrite')
            runCNMFe_dendrite(temp);
        end
    catch ME
        m=input_files{i};
        fprintf(['fail to process ',m,'\n'])
        rethrow(ME)
    end
    clearvars -except parin i
end