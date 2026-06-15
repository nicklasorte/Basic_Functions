function write_table_with_retry(app,table_data,file_name,pause_time)
retry_save=1;
while(retry_save==1)
    try
        writetable(table_data,file_name);
        retry_save=0;
    catch
        retry_save=1;
        pause(pause_time);
    end
end
end