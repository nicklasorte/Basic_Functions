function idx = findTextInCell(C, textValue)
%FINDTEXTINCELL Find index of text inside mixed cell array
%
%   idx = findTextInCell(C, textValue)
%
%   Works for cell arrays containing text and numeric values.

    % Keep only cells that contain text
    isText = cellfun(@(x) ischar(x) || isstring(x), C);

    % Convert those cells to string
    textCells = string(C(isText));

    % Find matches
    matchMask = matches(textCells, textValue);

    % Map back to original indices
    originalIdx = find(isText);
    idx = originalIdx(matchMask);

end
