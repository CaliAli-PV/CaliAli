function [neuron,mse,curr_mse]=register_neurons_ind(neuron,base_template,base_template_norm,template,template_norm,normalize,registration_method)
if normalize
    template=template_norm;
    base_template=base_template_norm;
end
template=double(template);
base_template=double(base_template);
R=imref2d(neuron.imageSize);

[optimizer, metric]=imregconfig('monomodal');
iter=1;
registrations={};
curr_template=template;

curr_mse=MSE_registration_metric(curr_template,base_template);
while iter<=length(registration_method);
    if isequal(registration_method{iter},'translation')||isequal(registration_method{iter},'affine')
        
        registration=registration2d(base_template,template,'transformationModel',registration_method{iter});
        test2=deformation(curr_template,registration.displacementField,registration.interpolation);
        try
            tform=imregtform(curr_template,base_template,registration_method{iter},optimizer,metric);
            test1=imwarp(curr_template,tform,'OutputView',R);
        catch
            warning('Requires image processing toolbox, defaulting to alternate registration method')
            test2=test;
            tform=registration;
        end
    elseif isequal(registration_method{iter},'rigid')||isequal(registration_method{iter},'similarity')
        try
            tform=imregtform(curr_template,base_template,registration_method{iter},optimizer,metric);
            test1=imwarp(curr_template,tform,'OutputView',R);
            registration=tform;
            test2=test1;
        catch
            warning('Requires image processing toolbox')
            test1=curr_template;
            test2=test1;
            tform=[];
            registration=[];
        end
    elseif isequal(registration_method{iter},'non-rigid')
        registration=registration2d(base_template,template,'transformationModel',registration_method{iter});
        test2=deformation(curr_template,registration.displacementField,registration.interpolation);
        tform=registration;
        test1=test2;
    else
        warning('Invalid registration method, ignoring current registration')
    end
        
        
        
    mse1=MSE_registration_metric(test1,base_template);
    mse2=MSE_registration_metric(test2,base_template);
    [~,I]=min([curr_mse,mse1,mse2]);
    if I==2
        registrations{end+1}=tform;
        curr_template=test1;
        curr_mse=mse1;
    elseif I==3
        registrations{end+1}=registration;
        curr_template=test2;
        curr_mse=mse2;
        
    end
    iter=iter+1;
end
        
for k=length(registrations):-1:1
    if isempty(registrations{k})
        registrations(k)=[];
    end
end

temp_A=reshape(neuron.A,neuron.imageSize(1),neuron.imageSize(2),[]);
parfor j=1:size(neuron.A,2)
    for k=1:length(registrations)
        if isequal(class(registrations{k}),'affine2d')
            tform=registrations{k};
            temp_A(:,:,j)=imwarp(temp_A(:,:,j),tform,'OutputView',R);
        elseif isequal(class(registrations{1}),'struct')
            registration=registrations{k};
            temp_A(:,:,j)=deformation(temp_A(:,:,j),registration.displacementField,registration.interpolation);
        end
            
    end
end
tempcn=double(neuron.Cn);
for k=1:length(registrations)
    if isequal(class(registrations{k}),'affine2d')
            tform=registrations{k};
            tempcn=imwarp(tempcn,tform,'OutputView',R);
        elseif isequal(class(registrations{1}),'struct')
            registration=registrations{k};
            tempcn=deformation(tempcn,registration.displacementField,registration.interpolation);
    end
end
neuron.Cn=tempcn;
neuron.A=reshape(temp_A,neuron.imageSize(1)*neuron.imageSize(2),[]);
neuron.A(neuron.A<10^(-6))=0;
mse=curr_mse;