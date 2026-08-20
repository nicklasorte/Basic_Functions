function X = convertStringOrNumeric(A)
%convertStringOrNumeric Convert text to number after removing spaces.
%
%   - Numeric input → returned as double
%   - String/char → spaces removed, then str2double
%   - Cell array → processed elementwise
%   - Otherwise → NaN
%
%   Example:
%       C = {"1 234", " 5. 6 ", 7, "8 9 0"};
%       X = convertStringOrNumeric(C)

    if iscell(A)
        X = NaN(size(A));
        for k = 1:numel(A)
            X(k) = convertOne(A{k});
        end
        return
    end

    % Non-cell input
    if isnumeric(A)
        X = double(A);
    elseif isstring(A) || ischar(A)
        X = convertOne(A);
    else
        X = NaN;
    end
end

function y = convertOne(v)

y = NaN;
if isnumeric(v) && isscalar(v)
    y = double(v);
end

if isstring(v) || ischar(v)
    s = string(v)
    % Remove ALL whitespace characters
    s = regexprep(s, '\s+', '')
    code = double(s);
    ok   = (code>=48 & code<=57) | ismember(code, double('+-.eEdD'))
    %s = regexp(s, '[\d\.]+', 'match', 'once')
    y = str2double(s)
    if isempty(y)
        'empty y'
        pause;
    end
end


end