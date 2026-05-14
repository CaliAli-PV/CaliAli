

[fileName, filePath] = uigetfile('*.mat', ...
    'Select the aligned.mat file containing the new unextracted data');
newFile = fullfile(filePath, fileName);

[fileName, filePath] = uigetfile('*.mat', ...
    'Select the source-extraction .mat file containing the existing neuron object');
sourceFile = fullfile(filePath, fileName);
[neuron, prev_F]=propagate_spatials(newFile,sourceFile);

neuron.retreat_neurons=true;

neuron=update_residual_Cn_PNR_batch_targeted(neuron,prev_F);

save_workspace(neuron);

neuron=manually_update_residuals(neuron,0.6,1,false);
