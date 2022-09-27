function [neurons,links]=register_neurons_links(neurons,links,registration_template,registration_type,registration_method,base)

reg_thresh=.2;
%Change this if normalizing neuron footprints prior to registration is 
%desirable.
normalize=false;

R=imref2d(neurons{1}.imageSize);
clear display_progress_bar
display_progress_bar('Aligning Recordings: ',false);
display_progress_bar(0,false);
if isequal(registration_template,'correlation')
    base_template=neurons{base}.Cn;
    base_template(base_template<.08)=0;
    base_template_norm=base_template;
else
    base_template_norm=max(reshape(neurons{base}.A./max(neurons{base}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
    base_template=max(reshape(neurons{base}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
end
templates{base}=base_template;
total_comp=0;
if isequal(registration_type,'align_to_base')
    for i=[1:base-1,base+1:length(neurons)]
        if isequal(registration_template,'correlation')
            template=neurons{i}.Cn;
            template(template<.08)=0;
            template_norm=template;
        else
            template_norm=max(reshape(neurons{i}.A./max(neurons{i}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            template=max(reshape(neurons{i}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
        end
        [temp,mse,curr_mse]=register_neurons_ind(neurons{i}.copy(),base_template,base_template_norm,template,template_norm,normalize,registration_method);
        if mse<curr_mse
            neurons{i}=temp;
        end
        if min(mse,curr_mse)>reg_thresh
            warning('Possible Poor Registration')
        
            
        end
        %    neurons{i}=thresholdNeuron(neurons{i},.3);
        total_comp=total_comp+1;
        display_progress_bar(total_comp/(length(neurons)-1)*100,false);
    end
else
    total=1;
    templates{base}=base_template;
    for i=base+1:length(neurons)
        if isequal(registration_template,'correlation')
            template_curr=neurons{i}.Cn;
            template_curr(template_curr<.08)=0;
            template_curr_norm=template_curr;
            
            template_prev=neurons{i-1}.Cn;
            template_prev(template_prev<.08)=0;
            template_prev_norm=template_prev;
        else
            template_curr=max(reshape(neurons{i}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            template_curr_norm=max(reshape(neurons{i}.A./max(neurons{i}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            
            template_prev=max(reshape(neurons{i-1}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            template_prev_norm=max(reshape(neurons{i-1}.A./max(neurons{i-1}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
        end
        [temp,mse,curr_mse]=register_neurons_ind(neurons{i}.copy(),template_prev,template_prev_norm,template_curr,template_curr_norm,normalize,registration_method);
        if mse<curr_mse
            neurons{i}=temp;
        end
        if min(mse,curr_mse)>reg_thresh
            warning('Possible Poor Registration')
        
            
        end
        total=total+1;
        display_progress_bar(total/(length(neurons)-1)*100,false);
    end
    
    for i=base-1:-1:1
        if isequal(registration_template,'correlation')
            template_curr=neurons{i}.Cn;
            template_curr(template_curr<.08)=0;
            template_curr_norm=template_curr;
            
            template_prev=neurons{i+1}.Cn;
            template_prev(template_prev<.08)=0;
            template_prev_norm=template_prev;
        else
            template_curr_norm=max(reshape(neurons{i}.A./max(neurons{i}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            template_curr=max(reshape(neurons{i}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
           
            
            template_prev_norm=max(reshape(neurons{i+1}.A./max(neurons{i+1}.A,[],1),neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
            template_prev=max(reshape(neurons{i+1}.A,neurons{1}.imageSize(1),neurons{1}.imageSize(2),[]),[],3);
        end
        
         [temp,mse,curr_mse]=register_neurons_ind(neurons{i}.copy(),template_prev,template_prev_norm,template_curr,template_curr_norm,normalize,registration_method);
        if mse<curr_mse
            neurons{i}=temp;
        end
        if min(mse,curr_mse)>reg_thresh
            warning('Possible Poor Registration')
        
            
        end
       total=total+1;
       
        display_progress_bar(total/(length(neurons)-1)*100,false);
    end
end

display_progress_bar(' Completed',false);
display_progress_bar('terminating',true)



clear display_progress_bar
if ~isempty(links)
    display_progress_bar('Aligning Connecting Recordings: ',false);
    display_progress_bar(0,false);

        total=0;
        
        for i=1:length(links)
            if isequal(registration_template,'correlation')
                template_curr=links{i}.Cn;
                template_curr(template_curr<.08)=0;
                template_curr_norm=template_curr;
                
                template_prev=neurons{i}.Cn;
                template_prev(template_prev<.08)=0;
                template_prev_norm=template_prev;
            else
                template_curr_norm=max(reshape(links{i}.A./max(links{i}.A,[],1),links{1}.imageSize(1),links{1}.imageSize(2),[]),[],3);
                template_curr=max(reshape(links{i}.A,links{1}.imageSize(1),links{1}.imageSize(2),[]),[],3);
                
                
                template_prev_norm=max(reshape(neurons{i}.A./max(neurons{i}.A,[],1),links{1}.imageSize(1),links{1}.imageSize(2),[]),[],3);
                template_prev=max(reshape(neurons{i}.A,links{1}.imageSize(1),links{1}.imageSize(2),[]),[],3);
            end
          
            [temp,mse,curr_mse]=register_neurons_ind(links{i}.copy(),template_prev,template_prev_norm,template_curr,template_curr_norm,normalize,registration_method);
            if mse<curr_mse
                links{i}=temp;
            end
            if min(mse,curr_mse)>reg_thresh
                warning('Possible Poor Registration')


            end
     
            total=total+1;
            display_progress_bar(total/(length(links))*100,false);
        end
        
    end
    
    display_progress_bar(' Completed',false);
    display_progress_bar('terminating',true)
    
    
end

