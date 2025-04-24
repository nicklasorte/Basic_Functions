function [poly_merge]=binary_shape_merge_rev1(app,cell_binary_merge)

if isempty(cell_binary_merge)==1
    poly_merge=cell_binary_merge;
else
    num_poly_dpa=length(cell_binary_merge);
    if num_poly_dpa>1
        tf_merge=1;
    else
        tf_merge=0;
    end
    tic;
    while(tf_merge==1)
        for i=1:2:num_poly_dpa
            horzcat(num_poly_dpa,i/num_poly_dpa*100)
            if i+1<=num_poly_dpa
                cell_binary_merge{i}=union(cell_binary_merge{i},cell_binary_merge{i+1});
                cell_binary_merge{i+1}=[];
            else
                cell_binary_merge{i}=cell_binary_merge{i};
            end
        end

        %%%%%Remove the empty cells
        cell_binary_merge=cell_binary_merge(~cellfun(@isempty,cell_binary_merge));

        num_poly_dpa=length(cell_binary_merge);
        if num_poly_dpa>1
            tf_merge=1;
        else
            tf_merge=0;
        end
        toc;
    end
    toc; %%%%%%1.9
    poly_merge=cell_binary_merge{:};
    poly_merge=rmholes(poly_merge);
end