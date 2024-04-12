function shuffledImage =shuffledIm(doubleImage)

% Define the size of the local neighborhood
neighborhoodSize = 3;  % You can adjust this based on your preference

% Get the size of the image
[rows, cols] = size(doubleImage);

% Initialize the shuffled image
shuffledImage = zeros(rows, cols);

% Iterate through each pixel
for i = 1:rows
    for j = 1:cols
        % Get the local neighborhood
        neighborhood = doubleImage(max(1, i-neighborhoodSize):min(rows, i+neighborhoodSize), ...
                                    max(1, j-neighborhoodSize):min(cols, j+neighborhoodSize));
        
        % Flatten the neighborhood and shuffle its values
        shuffledValues = neighborhood(:);
        shuffledValues = shuffledValues(randperm(length(shuffledValues)));
        
        % Assign the shuffled values back to the pixel
        shuffledImage(i, j) = shuffledValues(ceil(end/2));  % Take the center value
        
    end
end


