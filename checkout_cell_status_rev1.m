function [cell_status]=checkout_cell_status_rev1(app,checkout_filename,cell_status_filename,sim_folder,folder_names,tf_update_cell_status)

disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Entering Check Out: Line 3'))
%%%%%%%%%%%%%%%%Wait here until there is no checkout.
retry_tf_checkout=1;
retry_exists=1;

while(retry_tf_checkout==1)
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: While Loop 1: Line 9'))
    while(retry_exists==1)
        try
            disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: While Loop 1: Line 12'))
            tf_checkout=exist(checkout_filename,'file');
            retry_exists=0;
        catch
            retry_exists=1;
        end
    end
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: While Loop 1: Line 19'))
    
    if tf_checkout==0
        disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: While Loop 1: Line 22'))
        retry_tf_checkout=0;
        retry_exists=0;
    else
        disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Line 23: Waiting for checkout to be over . . . '))
        retry_tf_checkout=1;
        retry_exists=1;
        pause(0.2)
    end
end
disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Line 32'))
checkout=NaN(1,1);%%%%%%%Save a checkout file to stop
checkout(1)=1;
retry_save=1;
while(retry_save==1)
    try
        save(checkout_filename,'checkout')
        retry_save=0;
    catch
        retry_save=1;
    end
end
disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Saved Checkout Flag: Line 44'))

% end
%tf_checkout


%%%%%%%%%%%%%%%%%Load cell_status
retry_exists=1;
while(retry_exists==1)
    try
        cell_status_exist=exist(cell_status_filename,'file');
        retry_exists=0;
    catch
        retry_exists=1;
        pause(1)
    end
end


if cell_status_exist==2 %%%%%%%%Load
    retry_load=1;
    while(retry_load==1)
        try
            load(cell_status_filename,'cell_status')
            retry_load=0;
        catch
            retry_load=1;
            %%%%%%%%%%%%%%%%%%%Sometimes it seems we get an error here and
            %%%%%%%%%%%%%%%%%%%it just keeps trying to load.
        end
    end
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: cell_status loaded: Line 61'))
else
    [num_folders,~]=size(folder_names);
    cell_status=cell(num_folders,2); %%%%Name and 0/1
    cell_status(:,1)=folder_names;
    zero_cell=cell(1);
    zero_cell{1}=0;
    cell_status(:,2)=zero_cell;
    tf_update_cell_status=1;  %%%%%%%If we're creating a new one, we need to save it.
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Creating NEW cell_status: Line 82'))
end


%%%%%%%%%%%Update and Save cell_status
if tf_update_cell_status==1
    %%%%%Find the idx
    temp_cell_idx=strcmp(cell_status(:,1),sim_folder)==1;

    %%%%%%%Update the Cell
    cell_status(temp_cell_idx,2)={1};

    %%%%%Save the Cell
    retry_save=1;
    while(retry_save==1)
        try
            save(cell_status_filename,'cell_status')
            retry_save=0;
        catch
            retry_save=1;
            pause(2)
        end
    end
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: cell_status SAVED: Line 105'))
end

%%%%%%%%%%%%Checkout
%%%%%%Delete checkout
tf_delete=1;
while(tf_delete==1)
    try
        delete(checkout_filename)
        tf_delete=0;
    catch
        tf_delete=1;
    end
end


tf_checkout=exist(checkout_filename,'file');
if tf_checkout==1
    disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: PAUSE: Check out ERROR at end.'))
    pause;
end
disp_TextArea_PastText(app,strcat('checkout_cell_status_rev1: Exiting Checking Out: Line 126'))

end