function [elevation_m]=elevation_usgs_rev1(app,lat_pt,lon_pt)


    %%%%%%%Terrain Profile of a single point
%%%%%%%%%%Make this a function
if length(lat_pt)>1
    'Need to loop it'
    pause;
end

if isdeployed==1
    NET.addAssembly(which('SEADLib.dll'));
else
    NET.addAssembly(fullfile('C:\USGS', 'SEADLib.dll'));
end
USGS3Secp = TerrainPcs.USGS;
CoordTx = TerrainPcs.Geolocation(lat_pt,lon_pt);
CoordRx = TerrainPcs.Geolocation(lat_pt+0.001,lon_pt+0.001);
USGS3Secp.TerrainDataPath="C:\USGS";
Elev=double(USGS3Secp.GetPathElevation(CoordTx,CoordRx,90,true));  %%%%%%%%%This is the "z" equivalent
%%%%%%%%%%%%%%%%%%%%

elevation_m=Elev(1);

end