function inconus = CONUS_Plot
% CONUS_PLOT    returns a function handle, @inconus(lat, lon) that returns
% logical true for pairs of coordinates in CONUS and false otherwise
% (coordinates in degrees). As a side effect, it makes a geoplot of CONUS
% with thick borders and dashed lines marking state borders.

% reads in stl files of state boundaries, retrieved from census bureau pull
[S, A] = shaperead([fileparts(mfilename("fullpath")) filesep ...
    'cb_2023_us_state_20m' ...
    filesep 'cb_2023_us_state_20m.shp']);

% state/territory names, abrieviated
stusp = arrayfun(@(x)(string(x.STUSPS)), A);

% removes states/territories not in CONUS
low48 = S(~(strcmp(stusp, "AK") | strcmp(stusp, "HI") | ...
    strcmp(stusp, "PR")));


% array of polyshapes of states in CONUS
B = arrayfun(@(P)(polyshape(P.X, P.Y, Simplify=false)), low48);

% combines all states in CONUS into relatively simple sets of vertices
% composed of all land masses that make up CONUS
R = regions(simplify(rmholes(union(B))));
% R contains multiple regions, including some islands off of some coastal
% states. For the purpose of plotting, these regions are removed. The
% region that makes up the continental porrtion of CONUS is the one with 
% the most verticies, which is assigned to B.
% NOTE: if inconus is used for purposes other than finding points to plot,
% this might be problematic. Not all islands in CONUS are excluded by this
% process (New York City and Long Island are included) smaller islands that
% are further away from the continental portion of CONUS (such as
% Nantucket) are excluded.
nR = arrayfun(@(x)(numel(x.Vertices)), R);
B = R(nR == max(nR));

% B is now a single polyshape of CONUS, and a function handle inconus can
% be defined by applying B to inpolygon
inconus = @(lat, lon)(inpolygon(lon, lat, B.Vertices(:, 1), ...
    B.Vertices(:, 2)));

% stateconus are the vertices of each state that makes up CONUS that are
% included in B
stateconus = arrayfun(@(P)(inconus(P.Y, P.X)), low48, UniformOutput=false);
% instantiate polyshape array for each state
CONUS(numel(low48)) = polyshape;
for i = 1:numel(low48)
    % each state polyshape is defined from verticies of each state that are
    % included in B
    CONUS(i) = simplify(polyshape(low48(i).X(stateconus{i}), ...
        low48(i).Y(stateconus{i}), Simplify=false));
end

% plot state boundaries
for i = 1:numel(low48)
    geoplot(CONUS(i).Vertices(:, 2), CONUS(i).Vertices(:, 1), '-.k', ...
        HandleVisibility="off")
    hold on
end
% plot national boundaries
geoplot(B.Vertices(:, 2), B.Vertices(:, 1), 'k', LineWidth=4, ...
    HandleVisibility="off")
% national boundary plot appears jagged where verticies cluster. A
% scatterplot of these vertices overlaid on top smooths out this effect
geoscatter(B.Vertices(:, 2), B.Vertices(:, 1), 15, 'k', 'filled', ...
    HandleVisibility="off")

geobasemap landcover