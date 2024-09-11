function plot_alignment_scores(T,opt)

figure;
plot(T.(4){1,1}, '-k', 'DisplayName', 'Original');  % First trace
hold on;
plot(T.(4){2,1}, '-b', 'DisplayName', 'Translation');  % Second trace
plot(T.(4){3,1}, '--r', 'DisplayName', 'CaliAli');  % Third trace
hold off;
legend('show', 'Location', 'best');
xlabel("Session #");
ylabel("Neuron Correltion")
xlim([0.5,length(T.(4){1,1})+0.5])

plot_darkmode


ma=squeeze(sqrt(opt.shifts(:,:,1,:).^2+opt.shifts(:,:,2,:).^2));
ma=max(ma,[],3);
fprintf('The amplitude of non-rigid misalignment is %.1f%% of the average neuron size (%.1fpx).\n',prctile(ma(:),95)/(opt.gSig*3)*100,opt.gSig*3);

NRp=(1-mat2gray(T.('Mean Corr. Score')))*100;

fprintf('Non-rigid misalignment accounts for %.1f%% of the total.\n',NRp(2));
