function GCs_CNMFe_batch(parin)

for i=1:size(parin,1)
    try
    temp=parin{i,1:5};
    GCs_CNMFe(temp{:});
    catch ME
        m=parin{i,1};
        m=m{1,1};
        [~,m,~] = fileparts(m);
        fprintf(['fail to process ',m,'\n'])
        rethrow(ME)
    end
    clearvars -except parin i
end