function CNMFe_batch()


input_files = uipickfiles('FilterSpec','*_ds*.mat');


for i=1:size(input_files,1)
    try
    temp=input_files{i};

    runCNMFe_dendrite(temp);
    catch ME
        m=input_files{i};
        fprintf(['fail to process ',m,'\n'])
        rethrow(ME)
    end
    clearvars -except parin i
end