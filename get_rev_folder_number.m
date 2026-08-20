function [sim_number]=get_rev_folder_number(app,rev_folder)

% cd(rev_folder)
% pause(0.1)

retry_cd=1;
while(retry_cd==1)
    try
        cd(rev_folder)
        pause(0.1);
        retry_cd=0;
    catch
        retry_cd=1;
        pause(0.1)
    end
end
split_rev=strsplit(rev_folder,'\');
sim_string=strsplit(split_rev{end},'Rev');
sim_number=str2num(sim_string{end})
pause(0.1);


end