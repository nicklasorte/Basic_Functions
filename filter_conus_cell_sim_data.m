function [keep_idx]=filter_conus_cell_sim_data(app,tf_conus,cell_sim_data)

if tf_conus==1
    load('us_cont.mat','us_cont')
    min_lat=floor(min(us_cont(:,1))-2);
    max_lat=ceil(max(us_cont(:,1))+2);
    min_lon=floor(min(us_cont(:,2))-2);
    max_lon=ceil(max(us_cont(:,2))+2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    cell_data_header=cell_sim_data(1,:);
    col_header_lat_idx=find(matches(cell_data_header,'latitude'));
    col_header_lon_idx=find(matches(cell_data_header,'longitude'));
    [num_rows3,~]=size(cell_sim_data);
    keep_idx=NaN(num_rows3,1);
    keep_idx(1)=1;
    for i=2:1:num_rows3
        points_latlon=cell2mat(cell_sim_data(i,[col_header_lat_idx,col_header_lon_idx]));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        lon_idx1=find(min_lon<points_latlon(:,2));
        lon_idx2=find(max_lon>points_latlon(:,2));
        cut_lon_idx=intersect(lon_idx1,lon_idx2);

        lat_idx1=find(min_lat<points_latlon(:,1));
        lat_idx2=find(max_lat>points_latlon(:,1));
        cut_lat_idx=intersect(lat_idx1,lat_idx2);

        check_latlon_idx=intersect(cut_lon_idx,cut_lat_idx);
        if ~isempty(check_latlon_idx)
            keep_idx(i)=i;
        end
    end
    keep_idx=keep_idx(~isnan(keep_idx));
else
    [num_rows3,~]=size(cell_sim_data);
    keep_idx=1:1:num_rows3;
end

end