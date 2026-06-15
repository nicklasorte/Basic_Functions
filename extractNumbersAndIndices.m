function [nums, idx, row, col] = extractNumbersAndIndices(app,C)
%EXTRACTNUMBERSANDINDICES Extract numeric values and their indices
%
%   [nums, idx, row, col] = extractNumbersAndIndices(C)
%
%   Input
%   -----
%   C : cell array containing mixed data
%
%   Output
%   ------
%   nums : row vector of numeric scalar values found in C
%   idx  : linear indices of those values in C
%   row  : row subscripts (optional)
%   col  : column subscripts (optional)
%
%   Example
%   -------
%   C = {'Azimuth','Elevation',0,10,20};
%   [nums, idx] = extractNumbersAndIndices(C)

    % Logical mask for numeric scalars only
    mask = cellfun(@(x) isnumeric(x) && isscalar(x), C);

    % Linear indices
    idx = find(mask);

    % Extract numeric values
    nums = cell2mat(C(mask));

    % Optional row/column subscripts
    if nargout > 2
        [row, col] = ind2sub(size(C), idx);
    end

end
