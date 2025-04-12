function [cell_status]=init_or_load_cell_status_rev5(app,folder_names,cell_status_filename,checkout_filename)


 retry_exists=1;
     while(retry_exists==1)
         try
             var_exist=exist(cell_status_filename,'file');
             retry_exists=0;
         catch
             retry_exists=1;
             pause(1)
         end
     end


tf_try=1;
while tf_try==1
     retry_exists=1;
     while(retry_exists==1)
         try
             var_exist=exist(cell_status_filename,'file');
             retry_exists=0;
         catch
             retry_exists=1;
             pause(1)
         end
     end

    if var_exist==2 %%%%%%%%Load
        try
            load(cell_status_filename,'cell_status') %%%%%%%%%%%%%%%%%%%%Need to change this to keep checking persistent_var_exist_with_corruption in the while loop.
            tf_try=0;
        catch  error_msg
            temp_error_string=error_msg.message
            tf_try=1;
            pause(1)%%%%%%%%%%%%%%%Gets stuck here because the file is corrupted. Corruption happens when more than 1 server is trying to save to the file. The larger the file, the longer it takes to save, the more likely corruption occurs.
        end
    else
        tf_try=0;
    end

    if exist('cell_status','var')
        tf_try=0;
    else
        if var_exist==2
            tf_try=1;
        else
            tf_try=0;
        end
    end
end

 if exist('cell_status','var')
    [temp_size,~]=size(cell_status);
    [num_folders,~]=size(folder_names);
    if temp_size<num_folders
        disp_multifolder(app,'Pause for cell_status expansion')
        pause;
    end
 else %%%%%%Variable does not exist
    [num_folders,~]=size(folder_names);
    cell_status=cell(num_folders,2); %%%%Name and 0/1
    cell_status(:,1)=folder_names;
    zero_cell=cell(1);
    zero_cell{1}=0;
    cell_status(:,2)=zero_cell;
    %%%%%%Save

    disp_TextArea_PastText(app,strcat('init_or_load_cell_status_rev5: WARNING !!!! BLANK NEW cell_status '))
    pause;
    retry_save=1;
    while(retry_save==1)
        try
            save(cell_status_filename,'cell_status')
            retry_save=0;
        catch
            retry_save=1;
            pause(0.1)
        end
    end
 end
end

