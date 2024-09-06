function J = localHistMatch(Im, ref, win, patchOverlap, intensityThreshold)
    % localHistMatch performs local histogram matching of an image with overlapping patches,
    % ignoring regions below a certain intensity threshold.
    %
    % Inputs:
    %   Im              - Input grayscale image (MxN matrix).
    %   ref             - Reference grayscale image (MxN matrix).
    %   win             - Window size [height, width] for local processing.
    %   patchOverlap    - Overlap between patches [height, width].
    %   intensityThreshold - Minimum intensity value to include in processing.
    %
    % Output:
    %   J               - Image after local histogram matching.
    
    % Validate inputs
    if nargin ~= 5
        error('Five input arguments required: Im, ref, win, patchOverlap, and intensityThreshold.');
    end
    
    if ~ismatrix(Im) || ~ismatrix(ref)
        error('Input images must be grayscale (2D matrices).');
    end
    
    if numel(win) ~= 2 || any(win <= 0)
        error('Window size must be a vector with two positive integers.');
    end
    
    if numel(patchOverlap) ~= 2 || any(patchOverlap < 0)
        error('Patch overlap must be a vector with two non-negative integers.');
    end
    
    if ~isscalar(intensityThreshold) || intensityThreshold < 0
        error('Intensity threshold must be a non-negative scalar.');
    end
    
    % Convert images to grayscale if they are not already
    if size(Im, 3) == 3
        Im = rgb2gray(Im);
    end
    if size(ref, 3) == 3
        ref = rgb2gray(ref);
    end

    % Ensure the reference image has the same size as the input image
    [m, n] = size(Im);
    [ref_m, ref_n] = size(ref);
    if m ~= ref_m || n ~= ref_n
        error('Input image and reference image must have the same dimensions.');
    end

    % Create an empty image to store the result
    J = zeros(size(Im), 'like', Im);
    
    % Determine the window size and overlap
    windowHeight = win(1);
    windowWidth = win(2);
    overlapHeight = patchOverlap(1);
    overlapWidth = patchOverlap(2);
    
    % Compute the step size based on window size and overlap
    stepY = windowHeight - overlapHeight;
    stepX = windowWidth - overlapWidth;
    
    % Create a mask to keep track of valid pixels
    mask = false(size(Im));
    
    % Process the image in overlapping local regions
    for i = 1:stepY:m
        for j = 1:stepX:n
            % Define the window limits
            rowRange = i:min(i+windowHeight-1, m);
            colRange = j:min(j+windowWidth-1, n);
            
            % Extract the local region from the input image
            localRegion = Im(rowRange, colRange);
            localMask = localRegion > intensityThreshold;
            
            % Extract the local region from the reference image (same region)
            refRegion = ref(rowRange, colRange);
            
            % Apply mask to exclude low-intensity regions
            if any(localMask(:))
                % Perform histogram matching
                matchedRegion = imhistmatch(localRegion, refRegion);
               if max(matchedRegion,[],"all")>1
                dummy=1;
               end
                % Apply the mask to the matched region
                temp=Im(rowRange, colRange);
                
                matchedRegion(~localMask) = temp(~localMask);
                
                % Place the matched region back into the output image
                J(rowRange, colRange) = matchedRegion;
                
                % Update mask
                mask(rowRange, colRange) = mask(rowRange, colRange) | localMask;
            end
        end
    end
    
    % Normalize the output image to account for overlapping regions
    % J(mask) = J(mask) ./ (sum(mask(:)) / numel(J));
    
    % Ensure the output image is in the same format as the input
end
