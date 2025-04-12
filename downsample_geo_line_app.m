function [int_east46km]=downsample_geo_line_app(app,east46km,point_separation_dist)

[x7,~]=size(east46km);
east_dist_steps=NaN(x7-1,1);
for i=1:1:x7-1
    east_dist_steps(i)=deg2km(distance(east46km(i,1),east46km(i,2),east46km(i+1,1),east46km(i+1,2)));
end
num_pts=ceil(ceil(nansum(east_dist_steps))/point_separation_dist)+1;
int_east46km=curvspace_app(app,east46km,num_pts);

end

