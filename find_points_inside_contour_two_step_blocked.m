function [inside_idx,outside_idx] = find_points_inside_contour_two_step_blocked(app,contour_latlon,points_latlon,blockSize)
% Blocked two-step point-in-polygon to handle very large M robustly.

if nargin < 4 || isempty(blockSize)
    blockSize = 10000;%%%2e6;  % tune to your RAM (e.g., 2 million candidates per block)
end

M = size(points_latlon,1);
inside_mask = false(M,1);   % if even this is too big, see "streaming" note below

if isempty(contour_latlon) || isempty(points_latlon)
    inside_idx  = [];
    outside_idx = (1:M).';
    return
end

% Step 1: bounding box cut
min_lat = min(contour_latlon(:,1));
max_lat = max(contour_latlon(:,1));
min_lon = min(contour_latlon(:,2));
max_lon = max(contour_latlon(:,2));

lat = points_latlon(:,1);
lon = points_latlon(:,2);

in_bbox = lat > min_lat & lat < max_lat & lon > min_lon & lon < max_lon;
candidate_idx = find(in_bbox);

% Step 2: blocked inpolygon
xc = contour_latlon(:,2);
yc = contour_latlon(:,1);

K = numel(candidate_idx);
for k0 = 1:blockSize:K
    k1 = min(k0 + blockSize - 1, K);
    idx = candidate_idx(k0:k1);

    [in,on] = inpolygon(lon(idx),lat(idx),xc,yc);
    inside_mask(idx) = in | on;
end

inside_idx  = find(inside_mask);
outside_idx = find(~inside_mask);
end