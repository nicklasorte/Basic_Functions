function [temp_data]=data_check_missing_str2num_app(app,temp_data)

    if ismissing(temp_data)
        temp_data
        'Missing'
        pause;
    end
    if ischar(temp_data)
        temp_data=strrep(temp_data,char(160),'');
        temp_data=str2num(temp_data);
    end
    if isempty(temp_data)
        'Error: empty temp_data'
        temp_data
        pause;
    end