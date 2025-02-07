function plot_alignment_scores(CaliAli_options)
%% plot_alignment_scores: Visualize alignment scores across sessions.
%
% Inputs:
%   CaliAli_options - Structure containing inter-session alignment data.
%                     Details can be found in CaliAli_demo_parameters().
%
% Outputs:
%   None (generates a plot of alignment scores and prints misalignment statistics).
%
% Usage:
%   plot_alignment_scores(CaliAli_options);
%
% Notes:
%   - Plots neuron correlation scores before and after alignment.
%   - Computes and prints the amplitude of non-rigid misalignment relative to neuron size.
%   - Estimates the percentage contribution of non-rigid misalignment.
%   - Uses `plot_darkmode` for improved visibility in dark mode.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025


T=CaliAli_options.inter_session_alignment.alignment_metrics;
opt=CaliAli_options.inter_session_alignment;
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
drawnow;
