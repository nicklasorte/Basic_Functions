function [base_buffer]=geo_buffer_azi_rev1(app,base_protection_pts,azi_required_pathloss)

 [num_pp_pts,~]=size(base_protection_pts);
    if num_pp_pts>1
        %%%%%Preallocate
        cell_temp_lat_buff=cell(num_pp_pts,1);
        cell_temp_lon_buff=cell(num_pp_pts,1);
        for i=1:1:num_pp_pts
            [temp_lat,temp_lon] = track1(base_protection_pts(i,1),base_protection_pts(i,2),azi_required_pathloss(:,1),km2deg(azi_required_pathloss(:,3)),[],'degrees',1);
            cell_temp_lat_buff{i}=temp_lat;
            cell_temp_lon_buff{i}=temp_lon;
        end
        temp_lat_buff=vertcat(cell_temp_lat_buff{:});
        temp_lon_buff=vertcat(cell_temp_lon_buff{:});
        reshape_lat=reshape(temp_lat_buff,[],1);
        reshape_lon=reshape(temp_lon_buff,[],1);
        con_hull_idx=convhull(reshape_lon,reshape_lat); %%%%%%%%%%%Convex Hull
        base_buffer=horzcat(reshape_lat(con_hull_idx),reshape_lon(con_hull_idx));
    else
        %azi_required_pathloss
        %base_protection_pts
        [buff_lat,buff_lon] = track1(base_protection_pts(1),base_protection_pts(2),azi_required_pathloss(:,1),km2deg(azi_required_pathloss(:,3)),[],'degrees',1);
        base_buffer=horzcat(buff_lat',buff_lon');
        base_buffer=vertcat(base_buffer,base_buffer(1,:)); %%%%%%%Closing it up just in case
    end

end