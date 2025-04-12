function finish_cell_status_rev1(app,rev_folder,cell_status_filename)

[~,folder_names,~]=check_rev_folders(app,rev_folder);
[num_folders,~]=size(folder_names);
cell_status=cell(num_folders,2); %%%%Name and 0/1
cell_status(:,1)=folder_names;
cell_status(:,2)={1};
%%%%%%Save
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
cell_status

end