function [cell_compiled_data]=geo_sat_calc_rev1(app,cell_compiled_data,cell_data_header)



    str_tle_filename = strcat('full_geo.csv');   % use .csv so readtable detects commas
    str_website = 'https://celestrak.org/NORAD/elements/gp.php?GROUP=geo&FORMAT=csv';

    tic;
    outfilename = websave(str_tle_filename, str_website);
    toc;

    satData = readtable(str_tle_filename, 'FileType', 'text');   % auto-detects comma delimiter
    cell_tle = table2cell(satData);
    cell_tle_names = cellfun(@char, cell_tle(:,1), 'UniformOutput', false)';   % OBJECT_NAME col


    col_header_ele_idx=find(matches(cell_data_header,'Ground_Elevation_m'));
    col_header_gs_azimuth_idx=find(matches(cell_data_header,'gs_azimuth'));
    col_header_gs_elevation_idx=find(matches(cell_data_header,'gs_elevation'));
    col_header_base_ppts_idx=find(matches(cell_data_header,'base_protection_pts'));
    col_header_sat_id_idx=find(matches(cell_data_header,'Sat_ID'));

    [num_rows2,~]=size(cell_compiled_data);
    tic;
    for base_idx=1:1:num_rows2
        %base_idx
        %cell_compiled_data(base_idx,:)
        str_sat_name=cell_compiled_data{base_idx,col_header_sat_id_idx};
        temp_base_pts=cell_compiled_data{base_idx,col_header_base_ppts_idx};

        %%%%%%%%%%%%TLE Pull
        % % sat_row_idx=find(contains(cell_tle_names,'USA 272'))
        % % cell_tle_names{sat_row_idx}
        sat_row_idx=find(contains(cell_tle_names,str_sat_name));
        if isempty(sat_row_idx)
            str_sat_name
            'Satellite TLE not found'
            pause;

            % % % {'WGS 10 (USA 291)'        }
            % % % {'WGS F1 (USA 195)'        }
            % % % {'WGS F2 (USA 204)'        }
            % % % {'WGS F3 (USA 211)'        }
            % % % {'WGS F4 (USA 233)'        }
            % % % {'WGS F5 (USA 243)'        }
            % % % {'WGS F6 (USA 244)'        }
            % % % {'WGS F7 (USA 263)'        }
            % % % {'WGS F8 (USA 272)'        }
            % % % {'WGS F9 (USA 275)'        }
        end
        %single_tle=tleStruct(sat_row_idx);
        single_cell_tle=cell_tle(sat_row_idx,:);

        fields = {'OBJECT_NAME'
            'OBJECT_ID'
            'EPOCH'
            'MEAN_MOTION'
            'ECCENTRICITY'
            'INCLINATION'
            'RA_OF_ASC_NODE'
            'ARG_OF_PERICENTER'
            'MEAN_ANOMALY'
            'EPHEMERIS_TYPE'
            'CLASSIFICATION_TYPE'
            'NORAD_CAT_ID'
            'ELEMENT_SET_NO'
            'REV_AT_EPOCH'
            'BSTAR'
            'MEAN_MOTION_DOT'
            'MEAN_MOTION_DDOT'};
        single_tle=cell2struct(single_cell_tle,fields,2);
        single_tle_for_prop = struct();
        single_tle_for_prop.Epoch = single_tle.EPOCH;
        single_tle_for_prop.BStar = single_tle.BSTAR;
        single_tle_for_prop.RightAscensionOfAscendingNode = single_tle.RA_OF_ASC_NODE;
        single_tle_for_prop.Eccentricity = single_tle.ECCENTRICITY;
        single_tle_for_prop.Inclination = single_tle.INCLINATION;
        single_tle_for_prop.ArgumentOfPeriapsis = single_tle.ARG_OF_PERICENTER;
        single_tle_for_prop.MeanAnomaly = single_tle.MEAN_ANOMALY;
        single_tle_for_prop.MeanMotion=single_tle.MEAN_MOTION;
        single_tle_for_prop.Epoch = datetime(single_tle_for_prop.Epoch,'TimeZone', 'UTC');       % Force TLE epoch to UTC
        single_tle_for_prop.MeanMotion = single_tle.MEAN_MOTION * 2*pi / 1440;


        %%%%%%%%Pull in the RX (FSS) elevation
        [num_pp_pts,~]=size(temp_base_pts);
        if num_pp_pts>1
            'Need to generalize for more than 1 point'
            pause;
        end

        lat_pt=temp_base_pts(:,1);
        lon_pt=temp_base_pts(:,2);
        [elevation_m]=elevation_usgs_rev1(app,lat_pt,lon_pt);
        cell_compiled_data{base_idx,col_header_ele_idx}=elevation_m;

        %%%%%%%%%%%%%%%Set up the satellite Scenario
        sampleTime=60;
        startTime=datetime('now');
        stopTime=startTime+seconds(sampleTime);
        time=startTime:seconds(sampleTime):stopTime;
        % Force propagation time to UTC
        prop_time = datetime(time);
        prop_time.TimeZone = 'UTC';
        satscene=satelliteScenario(startTime,stopTime,sampleTime);
        %sat_position=propagateOrbit(datetime(time),single_tle);
        sat_time = datetime(time);
        sat_position = propagateOrbit(sat_time, single_tle_for_prop);
        positionTT=timetable(time',sat_position');
        constellation=satellite(satscene,positionTT);
        %%%%%%%%%%%%%%%%%%Create the ground stations
        temp_altitude=elevation_m+temp_base_pts(:,3)
        if isnan(temp_altitude)
            'NaN temp_altitude'
            pause;
        end
        earth_ground_stat=groundStation(satscene,lat_pt,lon_pt,'Altitude',temp_altitude);
        %%%%%%%%%%%%%%%Calculate the azimuth and elevation from the Earth to the Satellite
        [gs_azimuth,gs_elevation,gs_range]=aer(earth_ground_stat,constellation,stopTime);
        cell_compiled_data{base_idx,col_header_gs_azimuth_idx}=gs_azimuth;
        cell_compiled_data{base_idx,col_header_gs_elevation_idx}=gs_elevation;
        strcat(num2str(base_idx/num_rows2*100),'%')
        toc;
    end
    toc;

end