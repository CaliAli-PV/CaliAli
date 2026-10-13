function Cn = adjust_correlation_image(Cn)
%% adjust_correlation_image: Remove the background level of a correlation image and square it.
%
% Most pixels of a correlation image are background, so the most common value
% is the background level. This function subtracts that level and squares the
% result, which leaves the background near zero and the neurons standing out.
%
% Inputs:
%   Cn - Correlation image. Pixels equal to zero are not counted.
%
% Outputs:
%   Cn - Adjusted correlation image, same size as the input.
%
% Usage:
%   Cn = adjust_correlation_image(Cn);
%
% Notes:
%   - The background level is the highest point of a kernel density estimate
%     of the pixel values. Its smoothing is set in units of correlation, so the
%     level does not depend on the size of the frame. Only the lower half of
%     the range of values is searched.
%   - The level used to be read from a histogram with one bin per 100 pixels,
%     smoothed with a moving median 60 bins wide and searched only in its lower
%     half. On a small frame that window covers most of the histogram: at
%     72x116 pixels there are 84 bins, and removing one pixel from each side of
%     the frame moved the level from 0.449 to 0.593 with the image itself
%     unchanged. Because the result is squared, its 99th percentile went from
%     0.295 to 0.160, and so did everything that compares this image against a
%     threshold.
%
% Author: Pablo Vergara
% Contact: pablo.vergara.g@ug.uchile.cl
% Date: 2026

values = double(Cn(Cn ~= 0 & isfinite(Cn)));
if isempty(values)
    return
end

if min(values) == max(values)
    background = values(1);
else
    [density, level] = ksdensity(values, linspace(min(values), max(values), 1000));
    % Only the lower half of the range can be background. A session with frames
    % that motion correction got wrong has a correlation image that is high
    % nearly everywhere (median 0.80 instead of 0.60), and its most common value
    % is then that plateau (0.957): 80% of the pixels fell below the level and,
    % squared, became the whole image, so the session came out inverted and
    % correlated at -0.38 with the others. Searched below the middle, the level
    % stays on the background.
    lower = level <= (min(values) + max(values))/2;
    [~, I] = max(density(lower));
    background = level(I);
end

Cn = (Cn - background).^2;
end
