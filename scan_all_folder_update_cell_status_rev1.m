function scan_all_folder_update_cell_status_rev1(app,cell_status_filename,label_single_filename,rev_folder)


%%%%%%%%%%%%%Need to feed in the the folder names we need
[cell_status,folder_names]=initialize_or_load_generic_status_expand_rev2(app,rev_folder,cell_status_filename);
zero_idx=find(cell2mat(cell_status(:,2))==0);
size(cell_status)
size(zero_idx)


if ~isempty(zero_idx)==1
    temp_folder_names=folder_names(zero_idx)
    num_folders=length(temp_folder_names);

    %%%%%%%%Pick a random folder and go to the folder to do the sim
    reset(RandStream.getGlobalStream,sum(100*clock))  %%%%%%Set the Random Seed to the clock because all compiled apps start with the same random seed.
    [tf_ml_toolbox]=check_ml_toolbox(app);
    if tf_ml_toolbox==1
        array_rand_folder_idx=randsample(num_folders,num_folders,false);
    else
        array_rand_folder_idx=randperm(num_folders);
    end
    temp_folder_names(array_rand_folder_idx)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    [multi_hWaitbar,multi_hWaitbarMsgQueue]= ParForWaitbarCreateMH_time('Updgate cell_status: ',num_folders);    %%%%%%% Create ParFor Waitbar
    for folder_idx=1:1:num_folders
        sim_folder=temp_folder_names{array_rand_folder_idx(folder_idx)};
        temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

        [cell_status]=initialize_or_load_generic_status_while_rev4_debug(app,folder_names,cell_status_filename);  
        if cell_status{temp_cell_idx,2}==0
            %%%%%%%%%%Calculate
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

            %%%%%%Check to see if we need to make a new folder
            folder_row_idx=find(matches(folder_names,sim_folder))
            if isempty(folder_row_idx)
                %%%%%%%%No folder, so just skip
            else
                %%%%%%%%%%%%%%Go to the folder
                retry_cd=1;
                while(retry_cd==1)
                    try
                        cd(sim_folder)
                        pause(0.1);
                        retry_cd=0;
                    catch
                        retry_cd=1;
                        pause(0.1)
                    end
                end

                data_label1=sim_folder
                %%%%%%Check for the tf_complete file
                complete_filename=strcat(data_label1,'_',label_single_filename,'.mat'); %%%This is a marker for me
                [var_exist]=persistent_var_exist_with_corruption(app,complete_filename);
                if var_exist==2
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
                    %%%%%%%%Update the cell_status
                    [~]=update_generic_status_cell_rev1_debug(app,folder_names,sim_folder,cell_status_filename);
                end
            end
        end
        multi_hWaitbarMsgQueue.send(0);
    end
    delete(multi_hWaitbarMsgQueue);
    close(multi_hWaitbar);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%End of Update cell_status
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end