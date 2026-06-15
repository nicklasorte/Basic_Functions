function Aiq = interpRows(A, x, xq, method)
%INTERPROWS Interpolate each row of matrix A along columns.

    if nargin < 4 || isempty(method)
        method = "linear";
    end

    % Ensure column vectors
    x  = x(:);
    xq = xq(:);

    % Validate dimensions
    if length(x) ~= size(A,2)
        error('Length of x (%d) must equal number of columns of A (%d).', ...
              length(x), size(A,2));
    end

    % Interpolate rows via transpose trick
    Aiq = interp1(x, A.', xq, method, NaN).';

end

% %INTERPROWS Interpolate each row of a matrix A along its columns.
% %
% %   Aiq = interpRows(A, x, xq)
% %   Aiq = interpRows(A, x, xq, method)
% %   Aiq = interpRows(A, x, xq, method, extrapval)
% %
% % Inputs
% %   A         : M-by-N numeric matrix
% %   x         : 1-by-N or N-by-1 sample locations for columns of A
% %               (use x = 1:size(A,2) if you just want "column index" as x)
% %   xq        : query locations (vector)
% %   method    : 'linear' (default), 'pchip', 'spline', 'makima', etc.
% %   extrapval : optional extrapolation value (e.g. NaN). If omitted,
% %               interp1 extrapolates only if you pass 'extrap'.
% %
% % Output
% %   Aiq       : M-by-numel(xq) interpolated matrix
% 
%     if nargin < 4 || isempty(method), method = "linear"; end
% 
%     x  = x(:);          % N-by-1
%     xq = xq(:);         % Q-by-1
% 
%     if nargin < 5
%         % Interpolate without extrapolation (out-of-range -> NaN)
%         Aiq = interp1(x, A.', xq, method).';   % transpose trick
%     else
%         % Extrapolate with specified value
%         Aiq = interp1(x, A.', xq, method, extrapval).';
%     end
% end
