function [inside_idx]=find_points_inside_contour_two_step(app,contour_latlon,points_latlon)

%%%%%%%%Functionalize: Find points inside contour
%tic;
%%%%%%%%%%Convex hull to simplify
inside_idx=NaN(1,1);
if ~isempty(contour_latlon)
    %%%%%Rough cut first to speed it up.
    min_lat=min(contour_latlon(:,1));
    max_lat=max(contour_latlon(:,1));
    min_lon=min(contour_latlon(:,2));
    max_lon=max(contour_latlon(:,2));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    lon_idx1=find(min_lon<points_latlon(:,2));
    lon_idx2=find(max_lon>points_latlon(:,2));
    cut_lon_idx=intersect(lon_idx1,lon_idx2);

    lat_idx1=find(min_lat<points_latlon(:,1));
    lat_idx2=find(max_lat>points_latlon(:,1));
    cut_lat_idx=intersect(lat_idx1,lat_idx2);

    check_latlon_idx=intersect(cut_lon_idx,cut_lat_idx);

    if ~isempty(check_latlon_idx)
        num_lat_check=length(check_latlon_idx);
        inside_idx=NaN(num_lat_check,1);
        for pos_idx=1:1:num_lat_check
            pos_idx/num_lat_check*100
            tf_inside=inpolygon(points_latlon(check_latlon_idx(pos_idx),2),points_latlon(check_latlon_idx(pos_idx),1),contour_latlon(:,2),contour_latlon(:,1)); %Check to see if the points are in the polygon/contour
            if tf_inside==1
                inside_idx(pos_idx)=check_latlon_idx(pos_idx);
            end
        end
        inside_idx=inside_idx(~isnan(inside_idx));
    end
else
    inside_idx=NaN(1,1);
end

inside_idx=inside_idx(~isnan(inside_idx));
%toc;
