function [cell_status]=initialize_or_load_generic_status_while_rev4_debug(app,folder_names,cell_status_filename)

disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 3'))
tf_try=1;
while tf_try==1
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 6'))
    [var_exist_cell]=persistent_var_exist_with_corruption(app,cell_status_filename);
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 8:var_exist_cell:',num2str(var_exist_cell)))
    if var_exist_cell==2 %%%%%%%%Load
        try
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 11'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
            load(cell_status_filename,'cell_status') %%%%%%%%%%%%%%%%%%%%Need to change this to keep checking persistent_var_exist_with_corruption in the while loop.
            tf_try=0;
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 14'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
        catch
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 16'))
            tf_try=1;
            pause(3)%%%%%%%%%%%%%%%Gets stuck here because the file is corrupted. Corruption happens when more than 1 server is trying to save to the file. The larger the file, the longer it takes to save, the more likely corruption occurs.
        end
    else
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 21'))
        tf_try=0;
    end

    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 25'))
    if exist('cell_status','var')
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 27'))
        'cell_status exists'
        tf_try=0;
    else
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 31'))
        if var_exist_cell==2
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 33'))
            tf_try=1;
        else
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 36'))
            tf_try=0;
        end
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 39'))
    end
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 41'))
end
disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 43'))

 if exist('cell_status','var')
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 46'))  
    [temp_size,~]=size(cell_status);
    [num_folders,~]=size(folder_names);
    if temp_size<num_folders
        %%%%%Expand the cell
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 51'))
        disp_multifolder(app,'Pause for cell_status expansion')
        pause;
    end
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 55'))
 else %%%%%%Variable does not exist
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 57'))
    [num_folders,~]=size(folder_names);
    cell_status=cell(num_folders,2); %%%%Name and 0/1
    cell_status(:,1)=folder_names;
    zero_cell=cell(1);
    zero_cell{1}=0;
    cell_status(:,2)=zero_cell;
    %%%%%%Save
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: WARNING !!!! BLANK NEW cell_status '))
    retry_save=1;
    while(retry_save==1)
        try
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 68'))
            save(cell_status_filename,'cell_status')
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 70'))
            retry_save=0;
        catch
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 73'))
            retry_save=1;
            pause(0.1)
        end
    end
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 78'))
end
disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 80'))




% % %%%%%%%%%%%%Old Code Below
% % [num_folders,~]=size(folder_names);
% % [var_exist_cell]=persistent_var_exist_with_corruption(app,cell_status_filename);
% % disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 8'))
% % if var_exist_cell==2 %%%%%%%%Load
% %     retry_load=1;
% %     while(retry_load==1)
% %         try
% %             disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 13'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
% %             load(cell_status_filename,'cell_status') %%%%%%%%%%%%%%%%%%%%Need to change this to keep checking persistent_var_exist_with_corruption in the while loop.
% %             retry_load=0;
% %             disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 16'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
% %         catch
% %             retry_load=1;
% %             pause(0.1)
% %         end
% %     end
% %     [temp_size,~]=size(cell_status);
% %     if temp_size>num_folders
% %         %%%%%%%%Nothing
% %     elseif temp_size<num_folders
% %         %%%%%Expand the cell
% %         disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 27'))
% %         disp_multifolder(app,'Pause for cell_status expansion')
% %         pause;
% %         var_exist_cell=0;
% %     end
% %     disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 32'))
% % end
% %
% % if var_exist_cell==0 %%%%%%%%Initilize and Save
% %     disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 36'))
% %     [num_folders,~]=size(folder_names);
% %     cell_status=cell(num_folders,2); %%%%Name and 0/1
% %     cell_status(:,1)=folder_names;
% %     zero_cell=cell(1);
% %     zero_cell{1}=0;
% %     cell_status(:,2)=zero_cell;
% %     %%%%%%Save the initialize all_data_stats_binary
% %     retry_save=1;
% %     while(retry_save==1)
% %         try
% %             disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 47'))
% %             save(cell_status_filename,'cell_status')
% %             retry_save=0;
% %         catch
% %             retry_save=1;
% %             pause(0.1)
% %         end
% %     end
% %     disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 55'))
% % end
% % disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_while_rev4_debug: Line 57'))

end