function cd_with_retry(app,target_folder)
retry_cd=1;
while(retry_cd==1)
    try
        cd(target_folder);
        pause(0.1);
        retry_cd=0;
    catch
        retry_cd=1;
        pause(0.1);
    end
end
end