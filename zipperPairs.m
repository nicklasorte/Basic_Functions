function zippered_pair_idx = zipperPairs(us_rand_real_data)
%ZIPPERPAIRS  Fast nearest-neighbor pairing for (IDX,lat,lon) using KD-tree.
%
%   zippered_pair_idx = zipperPairs(us_rand_real_data)
%
% Input:
%   us_rand_real_data : n-by-3 matrix [IDX, lat(deg), lon(deg)]
%
% Output:
%   zippered_pair_idx : m-by-2 matrix of row indices into us_rand_real_data
%                      Each row is a unique undirected pair [i j] (sorted),
%                      and rows are sorted by column 1.
%
% Toolboxes:
%   Statistics and Machine Learning Toolbox: createns, knnsearch (KD-tree)
%   Mapping Toolbox (optional use): distance/deg2km if you want km later
%
% Why fast:
%   Convert lat/lon -> 3D unit vectors and do Euclidean KD-tree search.
%   No custom distance => no exhaustive O(n^2) scan.

n = size(us_rand_real_data,1);
lat = us_rand_real_data(:,2);
lon = us_rand_real_data(:,3);

% --- Map (lat,lon) -> unit sphere XYZ
% sph2cart expects azimuth & elevation in radians:
% azimuth = lon, elevation = lat, radius = 1. :contentReference[oaicite:3]{index=3}
az = deg2rad(lon);
el = deg2rad(lat);
[x,y,z] = sph2cart(az, el, 1);
XYZ = [x y z];

% --- KD-tree neighbor model (fast for Euclidean). :contentReference[oaicite:4]{index=4}
Mdl = createns(XYZ, "NSMethod","kdtree", "Distance","euclidean");

zippered_pair_idx = zeros(0,2);
unpaired = true(n,1);

% We’ll increase K only if needed (rare).
K = 2;                      % 1st neighbor is self, 2nd is nearest other
Kmax = min(50,n);           % safety cap for pathological leftovers

while any(unpaired)

    U = find(unpaired);
    if isempty(U), break; end

    % Query only the unpaired set, but neighbors are searched in full set
    nn = knnsearch(Mdl, XYZ(U,:), "K", K);   % size: numel(U)-by-K

    % Choose for each i its nearest STILL-unpaired neighbor (excluding self)
    prop = zeros(numel(U),1);

    for t = 1:numel(U)
        i = U(t);
        cand = nn(t,:).';
        cand = cand(cand ~= i);            % drop self
        cand = cand(unpaired(cand));       % keep only unpaired
        if ~isempty(cand)
            prop(t) = cand(1);
        end
    end

    ok = prop ~= 0;
    U2 = U(ok);
    P2 = prop(ok);

    if isempty(U2)
        % Nobody found a partner at this K: try increasing K.
        if K < Kmax
            K = min(K+3, Kmax);
            continue
        else
            break
        end
    end

    % Mutual proposals
    whoProposes = zeros(n,1);
    whoProposes(U2) = P2;

    mutual = false(numel(U2),1);
    for t = 1:numel(U2)
        i = U2(t);
        j = P2(t);
        mutual(t) = (whoProposes(j) == i);
    end

    I = U2(mutual);
    J = P2(mutual);

    if isempty(I)
        % No mutuals: broaden the candidate list.
        if K < Kmax
            K = min(K+3, Kmax);
            continue
        else
            break
        end
    end

    pairs = sort([I(:), J(:)], 2);
    pairs = unique(pairs, "rows");

    % Commit only if both endpoints still unpaired (defensive)
    keep = unpaired(pairs(:,1)) & unpaired(pairs(:,2));
    pairs = pairs(keep,:);

    zippered_pair_idx = [zippered_pair_idx; pairs]; %#ok<AGROW>
    unpaired(pairs(:)) = false;

    % After progress, reset K back to 2 for speed/stability
    K = 2;
end

% Final tidy
zippered_pair_idx = unique(sort(zippered_pair_idx,2), "rows");
zippered_pair_idx = sortrows(zippered_pair_idx, 1);

end