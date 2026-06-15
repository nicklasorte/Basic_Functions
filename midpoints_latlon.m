function [mid_latlon] = midpoints_latlon(app,lat1, lon1, lat2, lon2)
[arcDeg, az] = distance(lat1, lon1, lat2, lon2);
[latMid, lonMid] = reckon(lat1, lon1, arcDeg/2, az);
mid_latlon=horzcat(latMid, lonMid);
end