function [rough_points_latlon]=rough_point_inside_rev1(app,contour_latlon,points_latlon)

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
    rough_points_latlon=points_latlon(check_latlon_idx,:);
end