function [cell_status,folder_names]=initialize_or_load_generic_status_expand_rev2(app,rev_folder,cell_status_filename)
    [sim_number,folder_names,num_folders]=check_rev_folders(app,rev_folder);  %%%%%%%%%Double check of the folder_names since we might expanding
    %[num_folders,~]=size(folder_names);
    [var_exist_cell]=persistent_var_exist_with_corruption(app,cell_status_filename);
    if var_exist_cell==2 %%%%%%%%Load
        retry_load=1;
        while(retry_load==1)
            try
                load(cell_status_filename,'cell_status')
                retry_load=0;
            catch
                retry_load=1;
                pause(0.1)
            end
        end
         %%%%%%%%%%%%First always check names, instead of just size
        set_xor_names=setxor(cell_status(:,1),folder_names)
        if isempty(set_xor_names)
            %%%%%%%Nothing
        else
            %%%%%%%%%%Expand the folders
            %%%%Check for the condition where a folder may have been deleted?

            %%%%Check if any of the names are missing from cell_status
            %%%%cell_status(1,:)=[]
            non_member_idx=find(ismember(folder_names,cell_status(:,1))==0);
            non_member_name=folder_names(non_member_idx,:);
            deleted_folders=setdiff(non_member_name,set_xor_names);

            if ~isempty(deleted_folders)
                deleted_folders
                'Deleted Folder?: Pause and Check'
                pause;
            end

            zero_cell=cell(1);
            zero_cell{1}=0;
            set_xor_names(:,2)=zero_cell;
            expanded_cell_status=vertcat(cell_status,set_xor_names);
            cell_status=expanded_cell_status;
            %%%%%%Save the Expanded cell_status
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
    
    if var_exist_cell==0 %%%%%%%%Initilize and Save
        %[num_folders,~]=size(folder_names);
        cell_status=cell(num_folders,2); %%%%Name and 0/1
        cell_status(:,1)=folder_names;
        zero_cell=cell(1);
        zero_cell{1}=0;
        cell_status(:,2)=zero_cell;
        %%%%%%Save the initialize all_data_stats_binary
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