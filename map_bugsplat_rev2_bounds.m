function map_bugsplat_rev2_bounds(app,array_latlonpwr,bound_pts,title_str,filename_bugsplat)


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Map the Power
    [~,sort_idx]=sort(array_latlonpwr(:,3));
    sort_array_latlonpwr=array_latlonpwr(sort_idx,:);
    mode_color_set_angles=plasma(100);

    f1=figure;
    geoscatter(sort_array_latlonpwr(1,1),sort_array_latlonpwr(1,2),10,ceil(max(sort_array_latlonpwr(:,3))),'filled');
    hold on;
    geoscatter(sort_array_latlonpwr(1,1),sort_array_latlonpwr(1,2),10,floor(min(sort_array_latlonpwr(:,3))),'filled');
    geoscatter(sort_array_latlonpwr(:,1),sort_array_latlonpwr(:,2),10,sort_array_latlonpwr(:,3),'filled');
    geoplot(bound_pts(:,1),bound_pts(:,2),'-','Color','g','LineWidth',3,'DisplayName',strcat('ConvexHull'))
    cbh = colorbar;
    ylabel(cbh, 'Power [dBm]')
    colormap(f1,mode_color_set_angles)
    grid on;
    title({title_str})
    geobasemap streets-light%landcover
    f1.Position = [100 100 1200 900];
    pause(1)
    saveas(gcf,char(filename_bugsplat))
    pause(0.1);
    close(f1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end