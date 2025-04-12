function [cell_status]=initialize_or_load_generic_status_rev1_debug(app,folder_names,cell_status_filename)

    %cell_status_filename='cell_single_entry_status.mat'

    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 5'))
    [num_folders,~]=size(folder_names);
    [var_exist_cell]=persistent_var_exist_with_corruption(app,cell_status_filename);
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 8'))
    if var_exist_cell==2 %%%%%%%%Load
        retry_load=1;
        while(retry_load==1)
            try
                disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 13'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
                load(cell_status_filename,'cell_status') %%%%%%%%%%%%%%%%%%%%Need to change this to keep checking persistent_var_exist_with_corruption in the while loop.
                retry_load=0;
                disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 16'))  %%%%%%%%%Error after this point, doesn't hit the next checkpoint of Line 31.
            catch
                retry_load=1;
                pause(0.1)
            end
        end
        [temp_size,~]=size(cell_status);
        if temp_size>num_folders
            %%%%%%%%Nothing
        elseif temp_size<num_folders
            %%%%%Expand the cell
            disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 27'))
            disp_multifolder(app,'Pause for cell_status expansion')
            pause;
            var_exist_cell=0;
        end
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 32'))
    end
    
    if var_exist_cell==0 %%%%%%%%Initilize and Save
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 36'))
        [num_folders,~]=size(folder_names);
        cell_status=cell(num_folders,2); %%%%Name and 0/1
        cell_status(:,1)=folder_names;
        zero_cell=cell(1);
        zero_cell{1}=0;
        cell_status(:,2)=zero_cell;
        %%%%%%Save the initialize all_data_stats_binary
        retry_save=1;
        while(retry_save==1)
            try
                disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 47'))
                save(cell_status_filename,'cell_status')
                retry_save=0;
            catch
                retry_save=1;
                pause(0.1)
            end
        end
        disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 55'))
    end
    disp_TextArea_PastText(app,strcat('initialize_or_load_generic_status_rev1_debug: Line 57'))

end