function [curr_template,registrations]=register_projections(proj1,proj2,registration_method)



R=imref2d(size(proj1));

[optimizer, metric]=imregconfig('monomodal');
iter=1;
registrations={};
template=proj1;
curr_template=template;
curr_mse=MSE_registration_metric(curr_template,proj2);
while iter<=length(registration_method);
    if isequal(registration_method{iter},'translation')||isequal(registration_method{iter},'affine')
        
        registration=registration2d(proj2,template,'transformationModel',registration_method{iter});
        test2=deformation(curr_template,registration.displacementField,registration.interpolation);
        try
            tform=imregtform(curr_template,proj2,registration_method{iter},optimizer,metric);
            test1=imwarp(curr_template,tform,'OutputView',R);
        catch
            warning('Requires image processing toolbox, defaulting to alternate registration method')
            test2=test;
            tform=registration;
        end
    elseif isequal(registration_method{iter},'rigid')||isequal(registration_method{iter},'similarity')
        try
            tform=imregtform(curr_template,proj2,registration_method{iter},optimizer,metric);
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
        registration=registration2d(proj2,template,'transformationModel',registration_method{iter});
        test2=deformation(curr_template,registration.displacementField,registration.interpolation);
        tform=registration;
        test1=test2;
    else
        warning('Invalid registration method, ignoring current registration')
    end
        
        
        
    mse1=MSE_registration_metric(test1,proj2);
    mse2=MSE_registration_metric(test2,proj2);
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

