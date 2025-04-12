function [temp_lat]=convert_ddmmss_dd_lat_rev1(temp_lat)
    if ischar(temp_lat)
        if contains(temp_lat,'N')==1
            temp_split=strsplit(temp_lat,'N');
            temp_split_rx_lat=temp_split{1};
            if length(temp_split_rx_lat)==6
                temp_lat=str2num(temp_split_rx_lat(1:2))+str2num(temp_split_rx_lat(3:4))/60+str2num(temp_split_rx_lat(5:6))/360;
            else
                'Unknown legnth'
                temp_lat
                temp_split_rx_lat
                pause;
            end
        elseif contains(temp_lat,'S')==1
            temp_split=strsplit(temp_lat,'S');
            temp_split_rx_lat=temp_split{1};
            if length(temp_split_rx_lat)==6
                temp_lat=-1*(str2num(temp_split_rx_lat(1:2))+str2num(temp_split_rx_lat(3:4))/60+str2num(temp_split_rx_lat(5:6))/360);
            else
                'Unknown legnth'
                temp_lat
                temp_split_rx_lat
                pause;
            end
        end
    end
end