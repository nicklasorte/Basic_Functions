function [lat_dd,lon_dd]=convert_ddmmss_latlon_rev2(app,str_templat,str_templon)


    split1 = strsplit(str_templat,"°");
    split2=strsplit(split1{2},"'");
    split3=strsplit(split2{2},'"');
    temp_lat_ddmmss=horzcat(str2num(split1{1}),str2num(split2{1}),str2num(split3{1}));
    lat_dd=dms2degrees(temp_lat_ddmmss);

    split1 = strsplit(str_templon,"°");
    split2=strsplit(split1{2},"'");
    split3=strsplit(split2{2},'"');
    temp_lon_ddmmss=horzcat(str2num(split1{1}),str2num(split2{1}),str2num(split3{1}));
    lon_dd=-1*dms2degrees(temp_lon_ddmmss);
end
