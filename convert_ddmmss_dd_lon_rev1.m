function [temp_lon]=convert_ddmmss_dd_lon_rev1(temp_lon)

    if ischar(temp_lon)
        if contains(temp_lon,'E')==1
            temp_split=strsplit(temp_lon,'E');
            temp_split_rx_lon=temp_split{1};
            if length(temp_split_rx_lon)==6
                temp_lon=str2num(temp_split_rx_lon(1:2))+str2num(temp_split_rx_lon(3:4))/60+str2num(temp_split_rx_lon(5:6))/360;
            elseif length(temp_split_rx_lon)==7
                temp_lon=str2num(temp_split_rx_lon(1:3))+str2num(temp_split_rx_lon(4:5))/60+str2num(temp_split_rx_lon(6:7))/360;
            else
                'Unknown legnth'
                temp_lon
                temp_split_rx_lon
                pause;
            end
        elseif contains(temp_lon,'W')==1
            temp_split=strsplit(temp_lon,'W');
            temp_split_rx_lon=temp_split{1};
            if length(temp_split_rx_lon)==6
                temp_lon=-1*(str2num(temp_split_rx_lon(1:2))+str2num(temp_split_rx_lon(3:4))/60+str2num(temp_split_rx_lon(5:6))/360);
            elseif length(temp_split_rx_lon)==7
                temp_lon=-1*(str2num(temp_split_rx_lon(1:3))+str2num(temp_split_rx_lon(4:5))/60+str2num(temp_split_rx_lon(6:7))/360);
            else
                'Unknown legnth'
                temp_lon
                temp_split_rx_lon
                pause;
            end
        end
    end
end