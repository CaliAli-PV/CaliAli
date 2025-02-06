function ix=postprocessing_app(neuron,thr)
%% postprocessing_app: Interactive labeling and classification of CNMF-E components.
%
% Inputs:
%   neuron - CNMF-E neuron structure containing extracted components.
%   thr    - Threshold for drawing neuron contours.
%
% Outputs:
%   ix - Logical index of selected components, where selected components
%        are those labeled in all three projection views.
%
% Usage:
%   ix = postprocessing_app(neuron, 0.8);
%
% Description:
%   - This function initializes an interactive GUI (View_components) for 
%     manual labeling of CNMF-E-extracted components.
%   - The user can select components by left-clicking and remove them 
%     with a right-click.
%   - Additionally, this function provides an interface to classify spatial 
%     components using another interactive app (manually_classify_spatial).
%   - The function waits for the user to finish the selection process 
%     before returning the logical index of accepted components.
%   - Only components selected in all three views are included in `ix`.
%
% Notes:
%   - The View_components app provides multiple visualization tools such as:
%     * Different projection views (e.g., correlation, PNR, activity map)
%     * Zooming, component selection, and deletion
%     * Spatial separation of overlapping components
%   - The manually_classify_spatial app allows users to visually inspect 
%     and manually sort spatial components based on morphology.
%   - The function ensures synchronous execution by pausing until the 
%     user confirms selection via the "Done" button.
%
% Author: Pablo Vergara  
% Contact: pablo.vergara.g@ug.uchile.cl  
% Date: 2025                           
app=View_components(neuron,thr);
app.done=0;
while app.done == 0  % polling
    pause(0.05);
end

ix=sum(app.c,2)==3;

delete(app);