function T=get_alignment_metrics(P)

T=table();
Name={'Non-aligned','Translations','CaliAli','CaliAli+Neuron alignment'};
for i=1:size(P,2)
Neuo=mat2gray(squeeze(P.(i)(1,:).(5){1,1}(:,:,1,:)));
T=[T;create_table(Neuo,Name{i},'Neurons')];
end
% 
% for i=1:size(P,2)
% BVo=mat2gray(P.(i)(1,:).BloodVessels{1,1});
% T=[T;create_table(BVo,Name{i},'BV')];
% end

end


function out=create_table(in,reference_projection,test_projection)
pr=get_matched_projection(in);
[c,~,s] = motion_metrics(in);
out=table(categorical(string(reference_projection)),categorical(string(test_projection)),{pr},{c},mean(c),s, ...
    'VariableNames',{'Transformation','Test. Projection','Aligned Projections','Correlation scores','Mean Corr. Score','Crispness'});
end


