function [inside_idx,outside_idx,inside_mask] = find_points_inside_conus_buffer_rev2(app,points_latlon,buf_deg)
%FIND_POINTS_INSIDE_CONUS_BUFFER  Fast CONUS buffered bounding-box filter.
% Supports:
%   points_latlon : [M x 2]  -> point list [lat lon]
%               or [N x 4]  -> endpoint pairs [lat1 lon1 lat2 lon2]
%
% For [N x 4], inside_mask(i) is true if either endpoint is inside the bbox.

if nargin < 3 || isempty(buf_deg), buf_deg = 0; end

validateattributes(points_latlon, {'numeric'}, {'2d','real','finite'}, mfilename,'points_latlon',2); % :contentReference[oaicite:0]{index=0}
validateattributes(buf_deg,       {'numeric'}, {'scalar','real','finite','nonnegative'}, mfilename,'buf_deg',3); % :contentReference[oaicite:1]{index=1}

ncol = size(points_latlon,2);
if ~(ncol==2 || ncol==4)
    error('%s: points_latlon must be Mx2 ([lat lon]) or Nx4 ([lat1 lon1 lat2 lon2]).', mfilename);
end

N = size(points_latlon,1);
inside_mask = false(N,1);
inside_idx  = zeros(0,1);
outside_idx = (1:N).';

if N == 0
    return
end

% ---- load + cache bbox once (per buf_deg) ----
persistent min_lat max_lat min_lon max_lon last_buf
if isempty(min_lat) || isempty(last_buf) || last_buf ~= buf_deg

    S = load("us_cont.mat","us_cont");  % load specific var :contentReference[oaicite:2]{index=2}
    us_cont = S.us_cont;
    validateattributes(us_cont, {'numeric'}, {'2d','ncols',2,'real','finite'}, mfilename,'us_cont (from us_cont.mat)');

    min_lat = min(us_cont(:,1)) - buf_deg;
    max_lat = max(us_cont(:,1)) + buf_deg;
    min_lon = min(us_cont(:,2)) - buf_deg;
    max_lon = max(us_cont(:,2)) + buf_deg;

    last_buf = buf_deg;
end

% ---- bbox test ----
switch ncol
    case 2
        lat = points_latlon(:,1);
        lon = points_latlon(:,2);

        inside_mask = (lat > min_lat) & (lat < max_lat) & (lon > min_lon) & (lon < max_lon);

    case 4
        lat1 = points_latlon(:,1);  lon1 = points_latlon(:,2);
        lat2 = points_latlon(:,3);  lon2 = points_latlon(:,4);

        in1 = (lat1 > min_lat) & (lat1 < max_lat) & (lon1 > min_lon) & (lon1 < max_lon);
        in2 = (lat2 > min_lat) & (lat2 < max_lat) & (lon2 > min_lon) & (lon2 < max_lon);

        inside_mask = in1 | in2;      % either endpoint inside
        % inside_mask = in1 & in2;    % (alternative) both endpoints inside
end

inside_idx  = find(inside_mask);
outside_idx = find(~inside_mask);
end