function C = removeSpacesAndCommas(A)
%removeSpacesAndCommas Remove all spaces and commas from text.
%
%   C = removeSpacesAndCommas(A)
%
%   Input:
%       - char
%       - string
%       - string array
%       - cell array of char/string
%
%   Output:
%       - char vector (scalar input)
%       - cell array of char (array input)
%
%   Example:
%       C = removeSpacesAndCommas(' 1, 234 , 567 ')
%       % returns '1234567'

    % Convert to string first (uniform processing)
    S = string(A);

    % Remove all whitespace characters
    S = regexprep(S, '\s+', '');

    % Remove commas
    S = erase(S, ',');

    % Return char
    if isscalar(S)
        C = char(S);
    else
        C = cellstr(S);
    end
end