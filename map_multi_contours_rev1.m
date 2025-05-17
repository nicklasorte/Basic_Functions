function map_multi_contours_rev1(app,cell_multi_con,title_str,filename_bugsplat)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Map the Power
    [num_cirlces,~]=size(cell_multi_con)
    color_set3=plasma(num_cirlces);
    f1=figure;
    for i=1:1:num_cirlces
        temp_bound=cell_multi_con{i,2};
        temp_level=cell_multi_con{i,1};
        if ~isempty(temp_bound)
            geoplot(temp_bound(:,1),temp_bound(:,2),'-','Color',color_set3(i,:),'LineWidth',3,'DisplayName',strcat(num2str(temp_level),'dBm'))
            hold on;
        end
    end
    title({title_str})
    grid on;
    legend
    pause(0.1)
    %%%%geobasemap landcover
    geobasemap streets-light%landcover
    f1.Position = [100 100 1200 900];
    pause(1)
    saveas(gcf,char(filename_bugsplat))
    pause(0.1);
    close(f1)

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end