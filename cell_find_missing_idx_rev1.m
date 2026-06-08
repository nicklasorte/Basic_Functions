function [idx, subs, lin] = cell_find_missing_idx_rev1(A, opts)
%findMissingIndex  Find indices of missing-like values (robust).
%
%   idx = findMissingIndex(A) returns a logical array idx the same size as A,
%   marking entries that are missing-like.
%
%   [idx, subs, lin] = findMissingIndex(A) also returns:
%     subs - N-by-ndims(A) subscript indices (like ind2sub packed rows)
%     lin  - linear indices (find(idx))
%
%   This function is intentionally robust for:
%     - string:    <missing> (ismissing)
%     - numeric:   NaN (ismissing)
%     - datetime:  NaT (ismissing)
%     - categorical: <undefined> (ismissing)
%     - cell arrays:
%         * 1x1 missing (often produced by readcell)
%         * "" (empty string)   [optional]
%         * '' (empty char)     (ismissing treats {''} as missing)
%         * [] (empty)          [optional]
%         * NaN / NaT inside cells
%
%   opts (optional) fields:
%     opts.TreatEmptyStringAsMissing (default false)  % "" is NOT missing per MATLAB
%     opts.TreatEmptyArrayAsMissing  (default true)   % [] in a cell
%
%   Example:
%     C = {1, NaN, '', "", missing, datetime(NaT), [], "ok"};
%     [idx, subs, lin] = findMissingIndex(C, struct("TreatEmptyStringAsMissing",true))

    arguments
        A
        opts.TreatEmptyStringAsMissing (1,1) logical = false
        opts.TreatEmptyArrayAsMissing  (1,1) logical = true
    end

    % Fast path: non-cell inputs — trust MATLAB's missing definition.
    % ismissing defines missing by type (NaN, NaT, <missing>, <undefined>, {''} for cell of char, etc.).
    % See MathWorks documentation. :contentReference[oaicite:1]{index=1}
    if ~iscell(A)
        idx = ismissing(A);
        lin = find(idx);
        subs = localPackedSubscripts(size(A), lin);
        return
    end

    % Cell path: inspect each element robustly, without assuming uniform types.
    n = numel(A);
    idxFlat = false(n,1);

    for k = 1:n
        x = A{k};

        % 1) Explicit missing scalar (often 1x1 missing from readcell)
        if isequal(x, missing)   % safe even if x is not string
            idxFlat(k) = true;
            continue
        end

        % 2) Strings and chars
        if isstring(x)
            % MATLAB: ismissing(string) is true for <missing>. Empty string "" is NOT missing. :contentReference[oaicite:2]{index=2}
            idxFlat(k) = ismissing(x) || (opts.TreatEmptyStringAsMissing && any(strlength(x)==0));
            continue
        elseif ischar(x)
            % For char vectors in cells, treat '' as missing-like (matches MATLAB's cell-of-char missingness). :contentReference[oaicite:3]{index=3}
            idxFlat(k) = isempty(x);
            continue
        end

        % 3) Empty arrays inside a cell (optional)
        if isempty(x)
            idxFlat(k) = opts.TreatEmptyArrayAsMissing;
            continue
        end

        % 4) Numerics, datetimes, durations, categoricals, etc. inside cells
        % If ismissing supports the type, use it; otherwise fall through to false.
        try
            tf = ismissing(x);
            % If x is an array inside the cell, mark the cell missing if ANY element is missing.
            % This is usually what you want for "cell contains missing data".
            idxFlat(k) = any(tf(:));
        catch
            idxFlat(k) = false;
        end
    end

    idx = reshape(idxFlat, size(A));
    lin = find(idx);
    subs = localPackedSubscripts(size(A), lin);
end

function subs = localPackedSubscripts(sz, lin)
% Return an N-by-numel(sz) array of subscripts for linear indices lin.
    if isempty(lin)
        subs = zeros(0, numel(sz));
        return
    end
    c = cell(1, numel(sz));
    [c{:}] = ind2sub(sz, lin);
    subs = zeros(numel(lin), numel(sz));
    for j = 1:numel(sz)
        subs(:,j) = c{j}(:);
    end
end