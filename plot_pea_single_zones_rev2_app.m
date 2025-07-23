function plot_pea_single_zones_rev2_app(app,filename_PEA_plot,cell_pea_hist_poly)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%NationWide PEA map with the Overlapping
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

retry_load=1;
while(retry_load==1)
    try
        load('cell_pea_census_data.mat','cell_pea_census_data')
        pause(0.1)
        retry_load=0;
    catch
        retry_load=1;
        pause(1)
    end
end
%%%%%1)PEA Name, 2)PEA Num, 3)PEA {Lat/Lon}, 4)PEA Pop, 5)PEA Centroid, 6)Census {Geo ID}, 7)Census{Population}, 8)Census{NLCD}, 9)Census Centroid

tic;
%%%%%%%%cell_pea_hist
%%%1)Geo Id, 2)Covered Pop, 3)Uncovered Pop 4)Total Pop (Check), 5) Percentage Covered, 6) Percentage Available
%%%1)Covered Pop, 2)Uncovered Pop, 3)Covered Percentage,  4)Avaiable Percentage

pea_percentage=cell2mat(cell_pea_hist_poly(:,4))*100;
[number_markets]=length(pea_percentage);
pea_centroid=cell2mat(cell_pea_census_data(:,5));

%%%%%%%%%%%%%%
num_colors=100;
color_set=flipud(plasma(num_colors));
ny_font=2.5;

%%%%%%%How to remove Puerto Rico
pea_percentage(412)=NaN(1,1);
pea_percentage(414)=NaN(1,1);

%close all;
f1=figure;
AxesH = axes;
hold on;
%plot(state_lon,state_lat,'Color', [160/256 160/256 160/256])
for pea_idx=1:1:number_markets
    pea_idx/number_markets*100

    %%%%%%Plot the Boundary of the PEA
    temp_pea_bound=cell_pea_census_data{pea_idx,3};
    temp_lat=temp_pea_bound(:,1);
    temp_lon=temp_pea_bound(:,2);
    temp_cent=pea_centroid(pea_idx,:);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    temp_percentage=pea_percentage(pea_idx)/100;
    if ~isnan(temp_percentage)
        color_idx=ceil(num_colors.*temp_percentage);
        temp_round_percentage=round(temp_percentage*100);%,1);

        if color_idx==0
            color_idx=1;
        end

        %%%%%%%%Need to check for NaNs and plot each segment
        temp_idx_nan=find(isnan(temp_lon));
        num_segments=length(temp_idx_nan);
        for j=1:1:num_segments
            if j==1
                temp_idx=1:1:temp_idx_nan(j)-1;
            else
                temp_idx=temp_idx_nan(j-1)+1:1:temp_idx_nan(j)-1;
            end
            patch('Faces',1:1:length(temp_lon(temp_idx)),'Vertices',horzcat(temp_lon(temp_idx),temp_lat(temp_idx)),'EdgeColor',color_set(color_idx,:),'FaceColor',color_set(color_idx,:),'FaceAlpha',0.5,'EdgeAlpha',0.5)
        end
        plot(temp_pea_bound(:,2),temp_pea_bound(:,1),'-','Color',[160/256 160/256 160/256])
    end
end

for pea_idx=1:1:number_markets
    temp_percentage=pea_percentage(pea_idx)/100;
    if ~isnan(temp_percentage)
        temp_cent=pea_centroid(pea_idx,:);
        tx1=text(temp_cent(2),temp_cent(1),num2str(pea_idx));
        tx1.HorizontalAlignment = 'center';    %%%% set horizontal alignment to center
        tx1.VerticalAlignment ='middle';      %%%% set vertical alignment
        tx1.FontSize=ny_font;   %%%% make the text size based upon the population (LATER)
    end
end
h = colorbar('Location','south','Ticks',[0:0.1:1],'TickLabels',{'0%','10%','20%','30%','40%','50%','60%','70%','80%','90%','100%'});
ylabel(h, 'PEAs are shaded according to population availability','FontSize',7)
colormap(f1,color_set)
max_lon=-65;
min_lon=-125;
max_lat=50;
min_lat=25;
xlim([min_lon,max_lon])
ylim([min_lat,max_lat])

%%%%%%Center the plot and make the x/y span equal
if max_lon-min_lon>=max_lat-min_lat %%%%%%%%%%Add Buffer to y/lat
    graph_span=max_lat-min_lat;
    add_buff=((max_lon-min_lon)-graph_span)/6;
    ylim([min_lat-(add_buff*1.25),max_lat+(add_buff*.5)])
else %%%%%%%%%%Add Buffer to x/lon
    graph_span=max_lon-min_lon;
    add_buff=((max_lat-min_lat)-graph_span)/7;
    xlim([min_lon-add_buff,max_lon+add_buff])
end

InSet = get(AxesH, 'TightInset');
set(AxesH, 'Position', [InSet(1:2), 1-InSet(1)-InSet(3)-0.01, 1-InSet(2)-InSet(4)])
%%%%%%%%Make the x/y axis invisible
ax = gca;
ax.Visible = 'off';
print(gcf,filename_PEA_plot,'-dpng','-r300')
toc;
pause(1)
close(f1)

end