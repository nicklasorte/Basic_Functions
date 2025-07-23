function [matlab_ele_m]=matlab_elevation_rev1(app,lat_pt,lon_pt)
    temp_rxsite=rxsite(Name='TempSite',Latitude=lat_pt,Longitude=lon_pt);
    matlab_ele_m=elevation(temp_rxsite);
end