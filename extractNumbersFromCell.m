function [nums]=extractNumbersFromCell(app,C)
%EXTRACTNUMBERSFROMCELL Extract numeric values from cell array of strings
%
%   nums = extractNumbersFromCell(C)
%
%   Input
%   -----
%   C : cell array of character vectors or string array
%
%   Output
%   ------
%   nums : numeric array, same size as C
%          Non-numeric entries are returned as NaN
%
%   Example
%   -------
%   C = {'Azimuth','Elevation','0th%','10th%','20th','100th%'};
%   nums = extractNumbersFromCell(C)

    % Convert to string array for modern text handling
    S = string(C);

    % Extract digit sequences
    tokens = regexp(S, "\d+", "match", "once");

    % Convert to double (non-matches become NaN)
    nums = str2double(tokens);

    % Preserve original shape
    nums = reshape(nums, size(C));
end