function [norm_data, max_data, min_data] = zero_one_norm(data, max_data, min_data)

if nargin == 1
    max_data = max(data);
    min_data = min(data);
end

for j = 1:size(data,2)
    if max_data(j) - min_data(j) == 0
        norm_data(:,j) = zeros(size(data,1), 1);
    
    else
        norm_data(:,j) = -0.5 + ((data(:,j) - repmat(min_data(j), size(data,1), 1)) ./ repmat(max_data(j)-min_data(j), size(data,1), 1)) ;
        %(data - repmat(min_data, size(data,1), 1))./ repmat(max_data-min_data, size(data,1), 1) ;
    end
end