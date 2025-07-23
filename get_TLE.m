function [datetime, got_new_TLE]=get_TLE(time_zone)
%output data
% datetime: datetime in utc when the TLE file has been downloaded
% got_new_TLE: flag that indicate if the downloaded TLE (geo_new.txt) has some update comparing to the current TLE file (geo_current.txt)
%global time_zone; % multitask problem
geo_new = 'TLE_Data\geo_new.txt';           %new Geostationary TLE File
geo_current = 'TLE_Data\geo_current.txt';   %current Geostationary TLE File
fullURL = ['http://www.celestrak.com/NORAD/elements/geo.txt'];
date_time_utc = now - time_zone/24;
date_time_utc_str=datestr(date_time_utc,'yyyy_mm_dd_HH_MM_SS');
got_new_TLE=0; %flag to check if got the new TLE
if(exist(geo_current,'file')==2)
    file_name= geo_new;
else
    file_name= geo_current; % the first downloaded file
    write_file('TLE_Data\geo_current_date.txt',date_time_utc_str);
end
%[filestr,status] = urlwrite(fullURL,file_name,'Timeout',20);
%with out timeout... testing machine(matlab2012a) doesnt support Timeout
[filestr,status] = urlwrite(fullURL,file_name);
if (status == 1)
    %msgbox({filestr ; 'Succesful'});
    register_log('Get Geo TLE File Succesfully');
else
    %errordlg({'Cannot Get the TLE data from celestrack.com' ; 'check the internet connection'});
    register_log('Cannot Get the TLE data from celestrack.com');
end
if(exist(geo_current,'file')==2 && exist(geo_new,'file')==2 )
    text1 = fileread(geo_new);
    text2 = fileread(geo_current);
    if(strcmp(text1, text2))
        %the current TLE file has already updated...
        %msgbox('same');

        register_log('The Geo_New File and the Geo_Current File are the same');
    else
        %there is a new version of TLE File...
        %msgbox('not same');

        got_new_TLE=1;
        geo_current_date_str = get_file_line('TLE_Data\geo_current_date.txt');
        movefile(geo_current,['TLE_Data\geo_' geo_current_date_str '.txt']);


        register_log(['Backup of The Geo Current File has been made:' 'geo_' geo_current_date_str '.txt']);

        movefile(geo_new,geo_current);
        write_file('TLE_Data\geo_current_date.txt',date_time_utc_str);

        register_log('The Geo Current File has been updated with new TLE Data');
    end
end
datetime = date_time_utc_str;
datetime([5 8])='-';
datetime(11)=' ';
datetime([14 17])=':';

function note=get_file_line(filename)
% Open the file specified by filename.
[fid,msg] = fopen(filename,'r');
% Testing  if the file open operator is successful?
if fid > 0
    % write out the data to the file.
    note = fgetl(fid);
    % close the file
    status =  fclose(fid);
else
    % Open failed and display the message.
    errordlg(msg);
end


function register_log(msg_log)
filename = 'TLE_Data\log.txt';
% Open the file specified by filename.
[fid,msg] = fopen(filename,'a');
% Testing  if the file open operator is successful?
if fid > 0
    % write out the data to the file.
    date_time_str=datestr(now,'yyyy-mm-dd HH:MM:SS');

    count = fprintf(fid,'%s | %s\r\n',date_time_str , msg_log);
    % close the file
    status =  fclose(fid);
else
    % Open failed and display the message.
    errordlg(msg);
end