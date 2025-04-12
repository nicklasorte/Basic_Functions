function [cell_status]=update_generic_status_cell_rev1_debug(app,folder_names,sim_folder,cell_status_filename)


%%%%%%%Load
%[cell_status]=initialize_or_load_generic_status_rev1(app,folder_names,cell_status_filename)
disp_TextArea_PastText(app,strcat('update_generic_status_cell_rev1_debug: Line 6'))
%[cell_status]=initialize_or_load_generic_status_rev1_debug(app,folder_names,cell_status_filename)
 [cell_status]=initialize_or_load_generic_status_while_rev4_debug(app,folder_names,cell_status_filename);
disp_TextArea_PastText(app,strcat('update_generic_status_cell_rev1_debug: Line 9'))

%%%%%Find the idx
temp_cell_idx=find(strcmp(cell_status(:,1),sim_folder)==1);

%%%%%%%Update the Cell
cell_status{temp_cell_idx,2}=1;

%%%%%Save the Cell
retry_save=1;
while(retry_save==1)
    try
        disp_TextArea_PastText(app,strcat('update_generic_status_cell_rev1_debug: Line 21'))
        save(cell_status_filename,'cell_status')
        retry_save=0;
    catch
        retry_save=1;
        pause(2)
        disp_TextArea_PastText(app,strcat('update_generic_status_cell_rev1_debug: Line 27'))
    end
end
disp_TextArea_PastText(app,strcat('update_generic_status_cell_rev1_debug: Line 30'))
end