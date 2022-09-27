function decay_rate=estimate_decay_rate_from_signal(neuron,k)
neuron=neuron.copy();
if ~isempty(neuron.S)
    s_vals=neuron.S(k,(neuron.S(k,:)>0));
    s_vals=sort(s_vals,'descend');
    if length(s_vals)>0
        sthresh=.9*s_vals(ceil(length(s_vals)*1/2));
        speak_ind=find(neuron.S(k,:)>sthresh);
        speak=find(neuron.S(k,:)>0);
    else
        speak=[];
        speak_ind=[];
        decay_rate=NaN;
        return
    end
end

neuron.C=neuron.C_raw;

med_thresh=3*median(neuron.C(k,neuron.C(k,:)>0));
[cpeak_full,cval_full]=peakdet(neuron.C(k,:),med_thresh);
while max(size(cpeak_full,1),size(cval_full,1))>length(neuron.C(k,:))/75
    med_thresh=med_thresh*1.1;
    [cpeak_full,cval_full]=peakdet(neuron.C(k,:),med_thresh);
end
try
    cpeak_ind=cpeak_full(:,1)';
catch
    cpeak_ind=[];
    decay_rate=NaN;
    warning('few detected peaks')
    return
end
try
    cval_ind=cval_full(:,1)';
catch
    cval_ind=[];
    decay_rate=NaN;
    warning('few detected peaks')
    return
end
if ~isempty(neuron.S)
    dist=pdist2(cpeak_ind',speak_ind');
    minim=min(dist,[],2);
    cpeak_ind_good=cpeak_ind(minim<max(10,10*min(minim)));
else
    cpeak_ind_good=cpeak_ind;
end

if length(cpeak_ind_good)==0
    warning('spike and signal peak locations differ')
    decay_rate=NaN;
    return
end
c_thresh=.1*median(neuron.C(k,cpeak_ind_good));
cpeak_ind_good(neuron.C(k,cpeak_ind_good)<c_thresh)=[];
dist_length=zeros(1,length(cpeak_ind_good));
for j=1:length(cpeak_ind_good)
    min_val=min(ceil(length(neuron.C(k,:))/length(cpeak_ind_good)),length(neuron.C(k,:))-cpeak_ind_good(j)-1);
    temp_c=neuron.C(k,cpeak_ind_good(j):end);
    below_thresh_ind=find(temp_c<c_thresh);
    if length(below_thresh_ind)>0
        min_val=min(min_val,below_thresh_ind(1));
    end
    if max(cpeak_ind)>cpeak_ind_good(j)+1
        next_peak_ind=cpeak_ind(cpeak_ind>cpeak_ind_good(j)+1);
        min_val=min(min_val,next_peak_ind(1)-cpeak_ind_good(j)-1);
    end
    if max(cval_ind)>cpeak_ind_good(j)+1
        next_val_ind=cval_ind(cval_ind>cpeak_ind_good(j));
        min_val=min(min_val,next_val_ind(1)-cpeak_ind_good(j)-1);
    end
    if max(speak)>cpeak_ind_good(j)+1
        next_val_ind=speak(speak>cpeak_ind_good(j)+1);
        min_val=min(min_val,next_val_ind(1)-cpeak_ind_good(j)-1);
    end
    dist_length(j)=min_val;
end
cpeak_ind_good(dist_length<10)=[];
dist_length(dist_length<10)=[];
dist_length(dist_length>20)=20;
if length(cpeak_ind_good)<3
    warning('Less than 3 suitable peaks found')
    decay_rate=NaN;
    return
end
decay_rates=[];
% for j=1:length(cpeak_ind_good)
%     x{j}=0:dist_length(j)-1;
%     y{j}=smooth(neuron.C(k,cpeak_ind_good(j):cpeak_ind_good(j)+length(x{j})-1))';
%     f=fit(x',y','exp1');
%     decay_rates(j)=f.b;
% end
for j=1:length(cpeak_ind_good)
    x{j}=0:dist_length(j)-1;
    y{j}=smooth(neuron.C(k,cpeak_ind_good(j):cpeak_ind_good(j)+length(x{j})-1))';
end
vals=cell(1,max(cellfun(@length,x)));
for j=1:max(cellfun(@length,x))
    for p=1:length(x)
        if length(y{p})>j
            vals{j}(end+1)=y{p}(j)/y{p}(1);
        end
    end
end
y_full=[];
for j=1:length(vals)
    if length(vals{j})>1/2*length(x)
        y_full(j)=prctile(vals{j},33);
    end
end
%f=fit((0:length(y_full)-1)',y_full','exp1');
f=fit((0:length(y_full)-1)',y_full','exp(b*x)','StartPoint',[-.03]);
decay_rate=f.b;
% decay_rates(decay_rates>0)=[];
% decay_rates(isoutlier(decay_rates))=[];
% decay_rate=mean(decay_rates);


