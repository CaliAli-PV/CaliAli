function neuron=thresholdNeuron(neuron,prctile_thresh)
%Trims Sources2D or CNMF object's spatial footprints

%Inputs
%neuron (Sources2D)
%prctile_thresh (float range [0,1]) trim percentage of max pixel intensity

%Outputs
%neuron (Sources2D) object with trimmed neuron footprints

%%Author Kevin Johnston

%%
A=mat2cell(full(neuron.A),size(neuron.A,1),ones(1,size(neuron.A,2)));

data_shape=[neuron.options.d1,neuron.options.d2];

n=size(neuron.A,2);
parfor i=1:n
    A1=A{i};
    thresh=max(A1)*prctile_thresh;
    A1(A1<thresh)=0;
    
    A1=reshape(A1,data_shape(1),data_shape(2),[]);
    centroid=calculateCentroid(A1,data_shape(1),data_shape(2));
    bw=A1>0;
    stats=regionprops(bw,'MinorAxisLength');
    stats={stats.MinorAxisLength};
    stats=cell2mat(stats);
    len=max(stats);
    circle=createCirclesMask(data_shape,centroid,len/1.75);
    A1(circle==0)=0;
    A1=reshape(A1,data_shape(1)*data_shape(2),[]);
    
    A{i}=A1;
end
neuron.A=cell2mat(A);