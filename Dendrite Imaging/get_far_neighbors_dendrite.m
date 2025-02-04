function [out]=get_far_neighbors_dendrite(labeledImage,neuron)
gSig=neuron.CaliAli_options.downsampling.gSig;
PNR=neuron.CaliAli_options.inter_session_alignment.PNR;


seed=1:max(labeledImage,[],'all');
if numel(seed)>1
    di=min(gSig)*4*3;  %% maximum distance between neuron is 3 time the average neuron size
    %% Get pixel intensity
    D = calculateVesselDistances(labeledImage);
    D=D<di;

    for i=1:max(labeledImage,[],"all");
        intensisty(:,i)=mean((labeledImage==i).*PNR,'all');
    end

    %%
    out=[];
    while true
        if isempty(D)
            break
        end
        [~,I]=max(intensisty); %% get brightest seed (target seed).
        out=[out,seed(I)];
        %% remove seed too close to the target seed
        kill_seeds=logical(D(I,:));
        D(kill_seeds,:)=[];D(:,kill_seeds)=[];
        intensisty(kill_seeds)=[];
        seed(kill_seeds)=[];
        % Iterate until no seed are present
    end
else
    out=seed;
end

end




