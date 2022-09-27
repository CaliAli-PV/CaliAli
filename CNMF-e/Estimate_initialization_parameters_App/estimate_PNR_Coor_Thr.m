function [pnr_out,cn_out,mask]=estimate_PNR_Coor_Thr(Gsig,inF,min_corr,min_pnr);

% estimate_PNR_Coor_Thr(4)
if ~exist('Gsig','var')
Gsig=4;
end

if ~exist('min_corr','var')
min_corr=0.5;
end

if ~exist('min_pnr','var')
min_pnr=7;
end

if ~exist('inF','var')
warning('..._CnPNR.mat file does not exist!')
warning('Run ''get_CnPNR_from_video(gSig)'' ')
return
else
[path,file]=fileparts(inF); 
file2=[path,'\',file,'.mat'];
end
m=load(file2);


if ~isfield(m,'Mask')
    m.Mask=ones(size(m.Cn,1),size(m.Cn,2));
    Mask=m.Mask;
    save(file2,'Mask','-append');
end



app=estimate_Corr_PNR(m.Cn,m.PNR,Gsig,min_corr,min_pnr,logical(m.Mask));
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end
mask=app.mask;
pnr_out=app.PNRSpinner.Value;
cn_out=app.corrSpinner.Value;% get the values set in the parameter window
delete(app);





