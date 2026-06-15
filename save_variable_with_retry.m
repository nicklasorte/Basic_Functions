function save_variable_with_retry(app,file_name,variable_name,variable_data,pause_time)
retry_save=1;
while(retry_save==1)
    try
        save_struct=struct();
        save_struct.(variable_name)=variable_data;
        save(file_name,'-struct','save_struct');
        retry_save=0;
    catch
        retry_save=1;
        pause(pause_time);
    end
end
end