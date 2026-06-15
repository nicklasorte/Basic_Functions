function [inside_idx,outside_idx,inside_mask] = find_points_inside_conus_buffer(app,points_latlon,buf_deg)
%FIND_POINTS_INSIDE_CONUS_BUFFER  Fast CONUS buffered bounding-box filter.
%   [inside_idx,outside_idx,inside_mask] = find_points_inside_conus_buffer(app,points_latlon,buf_deg)
%
%   points_latlon : [M x 2] [lat lon]
%   buf_deg       : scalar buffer in degrees (>=0)
%
%   inside_idx    : indices of points inside buffered bbox
%   outside_idx   : indices of points outside buffered bbox
%   inside_mask   : logical mask (size Mx1)

% ---- argument handling (lightweight, fast) ----
tic;
if nargin < 3 || isempty(buf_deg), buf_deg = 0; end

validateattributes(points_latlon, {'numeric'},{'2d','ncols',2,'real','finite'}, mfilename,'points_latlon',2); % :contentReference[oaicite:0]{index=0}
validateattributes(buf_deg,       {'numeric'},{'scalar','real','finite','nonnegative'}, mfilename,'buf_deg',3); % :contentReference[oaicite:1]{index=1}

M = size(points_latlon,1);
inside_mask = false(M,1);
inside_idx  = zeros(0,1);
outside_idx = (1:M).';   % default; overwritten if needed

if M == 0
    return
end

% ---- load + cache coastline once ----
persistent min_lat max_lat min_lon max_lon last_buf

if isempty(min_lat) || isempty(last_buf) || last_buf ~= buf_deg
    % Load only the needed variable (faster + cleaner than loading everything)
    S = load("us_cont.mat","us_cont");  % :contentReference[oaicite:2]{index=2}
    us_cont = S.us_cont;

    validateattributes(us_cont, {'numeric'},{'2d','ncols',2,'real','finite'}, mfilename,'us_cont (from us_cont.mat)');

    % Buffered bbox; no need for floor/ceil unless you specifically want integer degrees
    min_lat = min(us_cont(:,1)) - buf_deg;
    max_lat = max(us_cont(:,1)) + buf_deg;
    min_lon = min(us_cont(:,2)) - buf_deg;
    max_lon = max(us_cont(:,2)) + buf_deg;

    last_buf = buf_deg;
end

% ---- bbox test (vectorized, memory-light) ----
lat = points_latlon(:,1);
lon = points_latlon(:,2);

inside_mask = (lat > min_lat) & (lat < max_lat) & (lon > min_lon) & (lon < max_lon);

inside_idx  = find(inside_mask);
outside_idx = find(~inside_mask);
toc;
end