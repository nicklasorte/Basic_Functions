function [cell_pea_hist_poly]=pea_impact_zone_rev2_app(app,cell_census_geoidx_poly)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%PEA Impact
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%PEA Table of o coordination zones'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

[num_peas,~]=size(cell_pea_census_data)
cell_pea_hist_poly=cell(num_peas,4); %%%1)Covered Pop, 2)Uncovered Pop, 3)Covered Percentage,  4)Avaiable Percentage
tic;

temp_census_geo_idx=cell_census_geoidx_poly{1,1};

for pea_idx=1:1:num_peas
    %%%%%%%%%%%%%%For each PEA, check to see which
    round((pea_idx/num_peas)*100)
    pea_census_geo_idx=cell_pea_census_data{pea_idx,6};
    pea_census_pop=cell_pea_census_data{pea_idx,7};
    num_pea_census=length(pea_census_geo_idx);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    temp_covered_match_idx=NaN(num_pea_census,1);
    for j=1:1:num_pea_census
        temp_idx=find(pea_census_geo_idx(j)==temp_census_geo_idx);
        if isempty(temp_idx)
            %%%Nothing
        else
            temp_covered_match_idx(j)=j;
        end
    end
    temp_covered_match_idx=temp_covered_match_idx(~isnan(temp_covered_match_idx));

    %%%%%%%%%Find the Population Covered in a PEA
    cell_pea_hist_poly{pea_idx,1}=sum(pea_census_pop(temp_covered_match_idx));  
  
    %%%%%%%%%%%Now find the Uncovered Geo Idx
    temp_all_idx=1:1:num_pea_census;
    temp_uncovered_match_idx=setxor(temp_all_idx,temp_covered_match_idx);

    %%%%%%%%%%%Uncovered Population
    cell_pea_hist_poly{pea_idx,2}=sum(pea_census_pop(temp_uncovered_match_idx));  %%%%%%Uncovered Pop

    %%%%%%%%%%%%%Covered Percentage
    cell_pea_hist_poly{pea_idx,3}=cell_pea_hist_poly{pea_idx,1}/sum(pea_census_pop);

    %%%%%%%%Uncovered/Available Percentage
    cell_pea_hist_poly{pea_idx,4}=cell_pea_hist_poly{pea_idx,2}/sum(pea_census_pop);
end
toc; %%%%


cell_pea_hist_poly
