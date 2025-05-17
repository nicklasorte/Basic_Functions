function [array_connect_idx,uni_connect_idx]=stitch_latlon_segments_rev1(app,cell_latlon)


[num_rows,~]=size(cell_latlon)
array_endpoint_latlon=NaN(num_rows,4);
for i=1:1:num_rows
    temp_latlon=cell_latlon{i};
    array_endpoint_latlon(i,1)=temp_latlon(1,1);
    array_endpoint_latlon(i,2)=temp_latlon(1,2);
    array_endpoint_latlon(i,3)=temp_latlon(end,1);
    array_endpoint_latlon(i,4)=temp_latlon(end,2);
end


%%Find the distance between points, and cut above this value
knn_idx=knnsearch(array_endpoint_latlon(:,[1,2]),array_endpoint_latlon(:,[3,4]),'k',1);
start_knn_array=array_endpoint_latlon(knn_idx,[1,2]);
knn_dist_bound=deg2km(distance(start_knn_array(:,1),start_knn_array(:,2),array_endpoint_latlon(:,3),array_endpoint_latlon(:,4)))%%%%Calculate Distance
%max_knn_dist=ceil(max(knn_dist_bound))

connect_idx=find(knn_dist_bound<1);
%%%%deg2km(distance(array_endpoint_latlon(knn_idx(1),1),array_endpoint_latlon(knn_idx(1),2),array_endpoint_latlon(1,3),array_endpoint_latlon(1,4)))

array_connect_idx=horzcat(knn_idx(connect_idx),connect_idx);
[num_conn,~]=size(array_connect_idx);
%%%%%%%%Only keep non-circular segments
for i=1:1:num_conn
    if array_connect_idx(i,1)==array_connect_idx(i,2)
        array_connect_idx(i,[1,2])=NaN(1,2);
    end
end
array_connect_idx=array_connect_idx(~isnan(array_connect_idx(:,1)),:);
uni_connect_idx=unique(reshape(array_connect_idx,[],1));
end