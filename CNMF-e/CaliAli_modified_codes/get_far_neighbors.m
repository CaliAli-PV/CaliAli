function [out]=get_far_neighbors(seed,d1,d2,gSiz,Cn,PNR)

di=sqrt(gSiz^2*2);  %% maximum distance between neuron
%% Get pixel intensity
Im=Cn.*PNR;
Im=Im(seed); 

%% Get seed distance
[r_peak, c_peak] = ind2sub([d1,d2],seed);
coor=[r_peak, c_peak];
D=squareform(pdist(coor));
D=D<di;

%% 
out=[];
while true
    if isempty(D)
        break
    end
    [~,I]=max(Im); %% get brightest seed (target seed).
    out=[out,seed(I)];
    %% remove seed too close to the target seed
    kill_seeds=logical(D(I,:)); 
    D(kill_seeds,:)=[];D(:,kill_seeds)=[]; 
    Im(kill_seeds)=[];
    seed(kill_seeds)=[];
    % Iterate until no seed are present
end