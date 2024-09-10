function F=get_batch_size(neuron,print_v)

if ~exist('print_v','var')
    print_v=1;
end
F=neuron.CaliAli_opt.F;

if neuron.CaliAli_opt.batch_sz>0
    F=diff(round(linspace(1,sum(F),round(sum(F)/neuron.CaliAli_opt.batch_sz)+1)));
end

if neuron.CaliAli_opt.dynamic_spatial==1
    ses=20;
    if length(F)<ses
        if print_v==1
            fprintf('---Minimun number of sessions for dynamic spatial is 20.\n');
            fprintf('Sessions will be split to achive this number!----------\n');
        end
        div=ceil(ses./length(F));
        T=[];
        for i=1:numel(F)
            sz=floor(F(i)./div);
            f=[repelem(sz,div-1),sz+F(i)-sz*div];
            T=[T,f];
        end
        if print_v==1
            fprintf('The smallest number of frame per batch will be: %d\n', min(T));
        end
        F=T;
    end
end