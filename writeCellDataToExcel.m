function writeCellDataToExcel(app, cell_data, filename, sheetName, writeMode, missingReplacement)
%WRITECELLDATATOEXCEL Write cell array data to Excel (robust missing handling).
%
%   writeCellDataToExcel(app, cell_data, "out.xlsx")
%   writeCellDataToExcel(app, cell_data, "out.xlsx", "Bands", "overwrite")
%   writeCellDataToExcel(app, cell_data, "out.xlsx", "Bands", "append", "NaN")
%
%   Converts unsupported cell elements (notably class 'missing') into a
%   supported representation before calling writecell.

    arguments
        app
        cell_data cell
        filename (1,1) string
        sheetName = 1
        writeMode (1,1) string = "overwrite"      % "overwrite" | "append"
        missingReplacement (1,1) string = "NaN"   % what to write instead of missing/empty
    end

    writeMode = lower(writeMode);
    if ~ismember(writeMode, ["overwrite","append"])
        error("writeMode must be 'overwrite' or 'append'.");
    end

    out = cell_data;

    for k = 1:numel(out)
        out{k} = localSanitize(out{k}, missingReplacement);
    end

    % Safety check: no 'missing' objects remain
    hasMissingObj = any(cellfun(@(v) isa(v,"missing"), out), "all");
    if hasMissingObj
        error("Sanitization failed: cell array still contains class 'missing'.");
    end

    writecell(out, filename, "Sheet", sheetName, "WriteMode", writeMode);
end


function v = localSanitize(v, missingReplacement)
% Convert unsupported types/values to Excel-friendly scalars.

    % 1) True missing objects (class 'missing')
    if isa(v,"missing")
        v = char(missingReplacement);
        return
    end

    % 2) Empty ([], {}, "")
    if isempty(v)
        v = char(missingReplacement);
        return
    end

    % 3) Strings (including string arrays)
    if isstring(v)
        % Replace missing elements inside string arrays
        m = ismissing(v);
        if any(m, "all")
            v(m) = missingReplacement;
        end

        if isscalar(v)
            v = char(v);                       % scalar string -> char
        else
            v = char(join(v, "; "));           % string array -> one cell text
        end
        return
    end

    % 4) Chars are fine (but if empty char, replace)
    if ischar(v)
        if isempty(v)
            v = char(missingReplacement);
        end
        return
    end

    % 5) Categoricals: convert undefined to replacement, then char
    if iscategorical(v)
        if any(isundefined(v), "all")
            v = char(missingReplacement);
        else
            v = char(string(v));
        end
        return
    end

    % 6) Tables inside a cell (rare): convert to string
    if istable(v)
        v = char(missingReplacement);
        return
    end

    % 7) Numerics/logicals/datetime/duration are supported as-is
end
