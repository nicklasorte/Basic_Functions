function [cell_census_geoidx_poly]=census_polygon_geoidx_app(app,cell_poly_merge)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Census Population Impact
load('Cascade_new_full_census_2010.mat','new_full_census_2010')
array_geo_idx=new_full_census_2010(:,1);
mid_lat=new_full_census_2010(:,2);
mid_lon=new_full_census_2010(:,3);

tic;
cell_census_geoidx_poly=cell(1,1); %%%%%1)(GEO_idx)
temp_poly=cell_poly_merge;

%%%%%%%%%%Population Impact (idx) and then total pop
%%%%%%%%Find the geo_id for each census tract, population, and NLCD value
tic;
num_cen=length(mid_lon);
inside_idx=NaN(num_cen,1);
for k=1:1:num_cen
    if ~isempty(temp_poly)
        temp_inside_idx=find(isinterior(temp_poly,mid_lon(k),mid_lat(k)));
        if ~isempty(temp_inside_idx)
            inside_idx(k)=k;
        end
    end
end
inside_idx=inside_idx(~isnan(inside_idx));
toc;
if ~isempty(inside_idx)
    cell_census_geoidx_poly{1,1}=array_geo_idx(inside_idx);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%