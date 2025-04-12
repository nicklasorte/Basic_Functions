function [temp_geo_poly]=convert_polyshape2geopolyshape(app,temp_polyshape)

 temp_latlon=temp_polyshape.Vertices;

        %%%%%%%Need to close all the polygons at the NaN
        nan_idx=find(isnan(temp_latlon(:,1)));
        if isempty(nan_idx)
            temp_lonlat_close=vertcat(temp_latlon,temp_latlon(1,:));
            %'Need to figure this out.'
            %pause;
        else
            num_regions=length(nan_idx)+1;
            temp_cell_latlon=cell(num_regions,1);
            for reg_idx=1:1:num_regions
                if reg_idx==1
                    temp_seg=temp_latlon(1:(nan_idx(reg_idx)-1),:);
                    temp_close_seg=vertcat(temp_seg,temp_seg(1,:),NaN(1,2));
                elseif reg_idx==num_regions
                    temp_seg=temp_latlon((nan_idx(reg_idx-1)+1):end,:);
                    temp_close_seg=vertcat(temp_seg,temp_seg(1,:));
                else
                    temp_seg=temp_latlon((nan_idx(reg_idx-1)+1):(nan_idx(reg_idx)-1),:);
                    temp_close_seg=vertcat(temp_seg,temp_seg(1,:),NaN(1,2));
                end
                temp_cell_latlon{reg_idx}=temp_close_seg;
            end
           temp_lonlat_close=vertcat(temp_cell_latlon{:});
          
        end
         temp_geo_poly=geopolyshape(temp_lonlat_close(:,2),temp_lonlat_close(:,1));

end