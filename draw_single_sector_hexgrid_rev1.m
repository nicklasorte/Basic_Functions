function [array_hex_centers]=draw_single_sector_hexgrid_rev1(app,num_tiers,ua_centroid,isd_azi_array,isd_km)


    %%%%%%%%%%%Function Single Sector Hexgrid 
    cell_hex_centers=cell(num_tiers,1); %%%%%1)Lat/Lon Center
    for tier_idx=1:1:num_tiers
        if tier_idx==1
            cell_hex_centers{tier_idx,1}=ua_centroid;
        elseif tier_idx==2
            %%%%Need to draw the 6 surrounding Base Station Centroid and the hex edge for each
            [cent_lat,cent_lon]=scircle1(ua_centroid(1),ua_centroid(2),km2deg(isd_km)*ones(length(isd_azi_array),1),isd_azi_array,[],'degrees',1);
            bs_cent=horzcat(cent_lat(1:end-1)',cent_lon(1:end-1)');
            cell_hex_centers{tier_idx,1}=bs_cent;
        else
            %%%%%%%%%%Need to draw centroids along the lines
            %%%%Need to draw the 6 surrounding Base Station Centroid and the hex edge for each
            x_radius=tier_idx-1;
            [cent_lat,cent_lon]=scircle1(ua_centroid(1),ua_centroid(2),km2deg(isd_km*x_radius)*ones(length(isd_azi_array),1),isd_azi_array,[],'degrees',1);

            edge_dist_km=deg2km(distance(cent_lat(1),cent_lon(1),cent_lat(2),cent_lon(2)));
            num_mid_line_points=ceil(edge_dist_km/isd_km)-1;
        
            cell_mid_points=cell(6,1);
            for edge_idx=1:1:6
                     [t_lat,t_lon1]=track2(cent_lat(edge_idx),cent_lon(edge_idx),cent_lat(edge_idx+1),cent_lon(edge_idx+1),[],'degrees',num_mid_line_points+2);
                     cell_mid_points{edge_idx,1}=horzcat(t_lat(2:end-1),t_lon1(2:end-1));
            end
            array_mix_centers=vertcat(cell_mid_points{:});
            bs_cent=horzcat(cent_lat(1:end-1)',cent_lon(1:end-1)');
            cell_hex_centers{tier_idx,1}=vertcat(bs_cent,array_mix_centers);

% % %             close all;
% % %             figure;
% % %             hold on;
% % %             plot(bs_cent(:,2),bs_cent(:,1),'or')
% % %             plot(array_mix_centers(:,2),array_mix_centers(:,1),'sb')
% % %             grid on;
% % %             pause(0.1)

        end
    end

    array_hex_centers=vertcat(cell_hex_centers{:});
    if length(array_hex_centers)~=length(unique(array_hex_centers,'rows'))
        'Might have to check out uniquing'
        pause;
    end


    %%%%%%%%%%Check if all the array_hex_centers are the ISD
    [idx_knn]=knnsearch(array_hex_centers,array_hex_centers,'k',7); %%%Find Nearest Neighbor
    hex_knn_array=array_hex_centers(idx_knn(:,2),:);
    knn_dist_bound=round(max(deg2km(distance(hex_knn_array(:,1),hex_knn_array(:,2),array_hex_centers(:,1),array_hex_centers(:,2)))),4); %%%%Calculate Distance

    if round(isd_km,4)~=knn_dist_bound
        'Might have an ISD problem'
        pause;
    end

end