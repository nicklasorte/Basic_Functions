function [cell_data]=load_full_excel_rev1(app,mat_filename_str,excel_filename,tf_repull)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Pull the Excel File and Save as a Mat File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[var_exist]=persistent_var_exist_with_corruption(app,mat_filename_str);
if tf_repull==1
    var_exist=0;
end

if var_exist==2 
    tic;
    load(mat_filename_str,'cell_data')
    toc;
else

    tic;
    cell_data=readcell(excel_filename);
    toc; %%%%%%%%%

    tic;
    save(mat_filename_str,'cell_data')
    toc;
end
