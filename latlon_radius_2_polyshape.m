function [cell_polygon]=latlon_radius_2_polyshape(app,array_latlon,buffer_radius_km)

%%%%%%%%%%%%%%%%%%%%Make a radius buffer
az=[];
ellipsoid=[];
n_pts=50;
[num_pts,~]=size(array_latlon);
%%%%%Preallocate
cell_polygon=cell(num_pts,1);
for i=1:1:num_pts
    [temp_lat_buff, temp_lon_buff]=scircle1(array_latlon(i,1),array_latlon(i,2),km2deg(buffer_radius_km),az,ellipsoid,'degrees',n_pts);
    cell_polygon{i}=polyshape(temp_lon_buff,temp_lat_buff);
end
%horzcat(temp_lat_buff, temp_lon_buff)

end