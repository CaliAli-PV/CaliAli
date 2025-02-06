function concatenated_array = concat_nan_centered(dim, varargin)
  % Concatenates arrays along specified dimension, padding with NaNs.
  % Adds successive dimensions if necessary.
  %
  %   concatenated_array = concat_with_padding(dim, array1, array2, ..., arrayN)
  %
  %   Inputs:
  %       dim: Dimension to concatenate along
  %       array1, array2, ..., arrayN: Arrays to concatenate
  %
  %   Output:
  %       concatenated_array: Concatenated array with NaN padding

  num_arrays = nargin - 1;
  padded_arrays = cell(1, num_arrays);
  max_dim=cellfun(@(x) size(x),varargin,'UniformOutput',false);
  max_dims = max(catpad(1,max_dim{:}),[],1,'omitnan');

  % Pad each array with NaNs
  for i = 1:num_arrays
    current_array = varargin{i};
    current_dims = size(current_array);
    dif=catpad(1,current_dims,max_dims);
    dif(isnan(dif))=0;
    dif=dif(1,:)-dif(2,:);

    pad_size = max_dims - current_dims;
    pre_pad = floor(pad_size / 2); 
    post_pad = pad_size - pre_pad; 

    pad_dims = cell(1, dim);
    for j = 1:dim
      pad_dims{j} = [pre_pad(j), post_pad(j)];
    end

    padded_arrays{i} = padarray(current_array, pad_dims, NaN);
  end

  % Concatenate the padded arrays along the specified dimension
  concatenated_array = cat(dim, padded_arrays{:});

end