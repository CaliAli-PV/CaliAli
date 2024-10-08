function neuron=update_residual_Cn_PNR_batch(neuron)
fprintf('Calculating residual Correlation and PNR imges...\n');
[Cn,PNR] = update_coor(neuron);

neuron.Cnr=Cn;
neuron.PNRr=PNR;
end


function [Cn,PNR] = update_coor(neuron)
d1=neuron.options.d1;
d2=neuron.options.d2;
gSig=neuron.options.gSig;
n_enhanced=neuron.n_enhanced;
fn=[0,cumsum(get_batch_size(neuron,0))];
for i=progress(1:size(fn,2)-1)
    Y = neuron.load_patch_data([],[fn(i)+1,fn(i+1)]);
    if ~ismatrix(Y); Y = reshape(Y, d1*d2, []); end % convert the 3D movie to a matrix
    Y(isnan(Y)) = 0;    % remove nan values
    %% substract neurons

    if isa(Y,'uint8')
        if ~isempty(neuron.A_batch)
            Y=Y-uint8(neuron.A_batch(:,:,i)*neuron.C(:,fn(i)+1:fn(i+1)));
        else
            Y=Y-uint8(full(neuron.A)*neuron.C(:,fn(i)+1:fn(i+1)));
        end
    else
        if ~isempty(neuron.A_batch)
            Y=Y-uint16(neuron.A_batch(:,:,i)*neuron.C(:,fn(i)+1:fn(i+1)));
        else
            Y=Y-uint16(full(neuron.A)*neuron.C(:,fn(i)+1:fn(i+1)));
        end
    end

    [~,Cn_all(:,:,i),pnr_all(:,:,i)]=get_PNR_coor_greedy_PV(reshape(Y,d1,d2,[]),gSig,[],[],n_enhanced);
end
Cn=mat2gray(max(Cn_all,[],3));
PNR=max(pnr_all,[],3);
end