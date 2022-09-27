function move_dependencies_to_folder(fList,outPath,NonExist_only)

% move_dependencies_to_folder(fList3,'H:\My Drive\GitHub\CaliAli\Data_paper\Compare methods\Scout_stuff',1);
%% STEPS to move scripts from one path to another avoiding duplication:


% 1) remove your current path, then add the path including all inputs scripts:

% 2) use this function to get dependencies:
% [fList,pList] = matlab.codetools.requiredFilesAndProducts('cell_tracking_main');fList=fList';

%3)  set path to default, then add the destination path :

%4) runt the code. be sure to set up NonExist_only =1, this way script that
%already exist in your path will not be overwriten

for i=1:size(fList,1)
    
    [~,name,ext] = fileparts(fList(i));
    
    if (NonExist_only==1)
        if (exist(name,'file')~=2)
            copyfile(char(fList(i)),[outPath,'\',name,ext]);
        end
    else
        copyfile(char(fList(i)),[outPath,'\',name,ext]);
    end
    
end