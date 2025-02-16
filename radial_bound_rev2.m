function [radial_bound]=radial_bound_rev2(app,sim_pt,keep_grid_pts,min_dist_km)

%%%%%%%Minimum Distance radial
[min_lat,min_lon] = scircle1(sim_pt(1),sim_pt(2),km2deg(min_dist_km-0.1),[],[],[],360);
keep_grid_pts=vertcat(keep_grid_pts,horzcat(min_lat,min_lon));

floor_grid_pt_azimuth=floor(azimuth(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2)));
ceil_grid_pt_azimuth=ceil(azimuth(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2)));
grid_pt_dist=ceil(deg2km(distance(sim_pt(1),sim_pt(2),keep_grid_pts(:,1),keep_grid_pts(:,2))));

dual_azi_dist=vertcat(horzcat(floor_grid_pt_azimuth,grid_pt_dist),horzcat(ceil_grid_pt_azimuth,grid_pt_dist));
%%%%For each uni_azi, find the max distance.
[uni_azi,~]=unique(dual_azi_dist(:,1));
num_uni_azi=length(uni_azi);
dual_max_azi_dist=uni_azi;
for i=1:1:num_uni_azi
    temp_row_idx=find(dual_azi_dist(:,1)==uni_azi(i));
    dual_max_azi_dist(i,2)=max(dual_azi_dist(temp_row_idx,2));
end

%dual_max_azi_dist

[first_radial_lat,first_radial_lon] = track1(sim_pt(1),sim_pt(2),dual_max_azi_dist(:,1),km2deg(dual_max_azi_dist(:,2)),[],'degrees',1);
first_radial_bound=horzcat(first_radial_lat',first_radial_lon');
radial_bound=vertcat(first_radial_bound,first_radial_bound(1,:));


% % % % f1=figure;
% % % % AxesH = axes;
% % % % hold on;
% % % % plot(radial_bound(:,2),radial_bound(:,1),'-xk','LineWidth',3)
% % % % scatter(keep_grid_pts(:,2),keep_grid_pts(:,1),20,'r','filled');
% % % % pause(0.1);
% % % % 'check radial bound to be closed'
% % % % pause;
% % % % close(f1)
% % % % 
% % % % 
% % % % %%%%%%%%Fill in the holes that don't have an azimuth
% % % % 
% % % % full_azi=[0:1:360]';
% % % % nn_full_azi_idx=nearestpoint_app(app,full_azi,dual_max_azi_dist(:,1));
% % % % size(nn_full_azi_idx)
% % % % size(dual_max_azi_dist)
% % % % full_dual_max_azi_dist=horzcat(full_azi,dual_max_azi_dist(nn_full_azi_idx,2));
% % % % [radial_lat,radial_lon] = track1(sim_pt(1),sim_pt(2),full_dual_max_azi_dist(:,1),km2deg(full_dual_max_azi_dist(:,2)),[],'degrees',1);
% % % % radial_bound=horzcat(radial_lat',radial_lon');
% % % % radial_bound=vertcat(radial_bound,radial_bound(1,:));
% % % % 
% % % % % % f1=figure;
% % % % % % AxesH = axes;
% % % % % % h3=plot(radial_bound(:,2),radial_bound(:,1),'-k','LineWidth',3,'DisplayName','Concave Coordination Zone')
% % % % % % pause(0.1);
% % % % % % 'check radial bound to be closed'
% % % % % % pause;
% % % % % % close(f1)



end