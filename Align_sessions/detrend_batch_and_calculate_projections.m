function CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options)
%% detrend_batch_and_calculate_projections: Perform detrending and projection calculations for batch processing.
%
% This function processes a batch of input files by applying detrending,
% calculating projections, and saving the transformed data. It updates the
% CaliAli_options structure with the computed results.
%
% Inputs:
%   CaliAli_options - Structure containing configuration options for the alignment process.
%                     The details of this structure can be found in
%                     CaliAli_demo_parameters().
%
% Outputs:
%   CaliAli_options - Updated structure with calculated projections and other results.
%
% Usage:
%   CaliAli_options = detrend_batch_and_calculate_projections(CaliAli_options);
%
% Steps:
%   1. Loads input files and checks for existing processed files.
%   2. Applies detrending and calculates projections if not already done.
%   3. Computes key features such as maximum projections, PNR, and correlation images.
%   4. Saves the detrended data and calculated projections for further alignment.
%
% Notes:
%   - If projections and detrending have already been performed for a file,
%     the function skips redundant processing.
%   - Detrended data is stored in separate output files with the suffix '_det.mat'.
%   - The function supports batch processing of multiple input files.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2025

% Extract the options related to inter-session alignment
opt = CaliAli_options.inter_session_alignment;

% If no input files are specified, prompt the user to select input files
if isempty(opt.input_files)
    opt.input_files = uipickfiles('FilterSpec','*.mat');
end

apply_crop_on_disk_backward_compatibility(opt.input_files);

[opt.input_files] = create_batch_list(opt.input_files, opt.batch_sz,'_det');


[process_flags,out_pre] = pre_allocate_outputs(opt.input_files,'_det');
try
    % Initialize the options structure for further use
    opt_g = opt;

    % Loop over each input file
    for k = 1:length(opt_g.input_files)
        % Get the full file name and separate the file path and name
        if ischar(opt_g.input_files{k})
            fullFileName = opt_g.input_files{k};
            fprintf(1, 'Now reading %s\n', fullFileName);
            intra_sess_tag= false;
            ses_ix=k;
            [filepath, name] = fileparts(fullFileName);
            if ~contains(name, '_det')
                output_file = strcat(filepath, filesep, name, '_det', '.mat');
            else
                output_file = strcat(filepath, filesep, name, '.mat');
            end
        else
            fullFileName = opt_g.input_files{k}{1};
            fprintf(1, 'Processing batch from %s\n', fullFileName);
            ses_ix=opt_g.input_files{k}{2};
            if opt_g.input_files{k}{3}>1
                intra_sess_tag= true;
            else
                intra_sess_tag= false;
            end
            output_file = opt_g.input_files{k}{5};
        end

        % If the output file does not exist, perform detrending and projection calculation
        if process_flags(k)
            fprintf(1, 'Detrending and calculating relevant projections for %s\n', fullFileName);

            % Load the data from the input file
            Y = CaliAli_load(opt_g.input_files{k}, 'Y');
            if intra_sess_tag
                [Y, P2, R, opt] = get_projections_and_detrend(Y, opt_g);
                range(ses_ix)=max([range(ses_ix),R]);
                F(ses_ix)=F(ses_ix)+size(Y, 3);
                Cn_scale=max([Cn_scale,max(P2.(3){1, 1}, [], 'all')]);
                Cn= max(cat(3, Cn,max(P2.(3){1, 1}, [], 3)),[],3);
                PNR=max(cat(3,PNR,max(P2.(4){1, 1}, [], 3)),[],3);
                P=add_P_inner_batches(P,P2);
            else
                % Detrend the data and calculate projections
                [Y, P, range(ses_ix), opt] = get_projections_and_detrend(Y, opt_g);
                % Calculate the size of the data (number of frames)
                F(ses_ix) = size(Y, 3);
                % Calculate the maximum projections and scale them
                Cn = max(P.(3){1, 1}, [], 3);
                Cn_scale = max(Cn, [], 'all');
                % Calculate the non-rigid projections (PNR)
                PNR = max(P.PNR{1, 1}, [], 3);
            end

            opt.range = range(ses_ix) ;
            opt.Cn_scale=Cn_scale;
            opt.Cn = Cn ./ opt.Cn_scale;
            opt.PNR = PNR;
            opt.F = F(ses_ix);
            opt.P = scaleP(P);

            % Update the CaliAli_options structure with the modified options
            CaliAli_options=CaliAli_load(opt_g.input_files{k}, 'CaliAli_options');
            CaliAli_options.inter_session_alignment = opt;
            % Save the updated options to the output file
            CaliAli_save(opt_g.input_files{k}(:), Y, CaliAli_options);
        else
            % If the output file already exists, load the pre-calculated options
            temp = CaliAli_load(opt_g.input_files{k}{5}, 'CaliAli_options.inter_session_alignment');
            range(ses_ix) = temp.range; %#ok
            F(ses_ix) = temp.F;
            % Inform the user that the calculation has already been done for this file
            fprintf(1, 'Calculation of projections and detrending is already done for file "%s".\n', opt_g.input_files{k}{1});
        end
    end

    % Restore the original options and update the output file list and other fields
    opt = opt_g;
    opt.range = range;
    opt.F = F;
    opt.output_files=unique(cellfun(@(x) x{1,5},opt.input_files,'UniformOutput',false));


    % Update the CaliAli_options structure with the final options
    CaliAli_options.inter_session_alignment = opt;

catch ME
    if exist(out_pre{1}, 'file') == 2
        delete(out_pre{:});
        fprintf(1, 'Deleted incomplete files due to error.\n');
    end
    fprintf(1, 'Motion correction failed: %s\n', ME.message);
    rethrow(ME);
end
end


function P=add_P_inner_batches(P1,P2)
P=P1;

P.(1){1, 1}=sum(cat(3,P1.(1){1, 1},P2.(1){1, 1}), 3);
P.(2){1, 1}=sum(cat(3,P1.(2){1, 1},P2.(2){1, 1}), 3);
P.(3){1, 1}=max(cat(3,P1.(3){1, 1},P2.(3){1, 1}), [], 3);
P.(4){1, 1}=max(cat(3,P1.(4){1, 1},P2.(4){1, 1}), [], 3);
P.(5){1, 1}=max(cat(4,P1.(5){1, 1},P2.(5){1, 1}), [], 4);

end

function P=scaleP(P)
for i=1:5
    P.(i){1, 1}=P.(i){1, 1}./max(P.(i){1, 1},[],'all');
end

end
