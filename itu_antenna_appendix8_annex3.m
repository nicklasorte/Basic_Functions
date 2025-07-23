function [array_gain]=itu_antenna_appendix8_annex3(app,FreqMHz,ant_diamter_m,ant_gain_dBi,phi_array)


disp_TextArea_PastText(app,strcat('Part0 Grid Points:ITU Appendix 8-Annex 3:Line 4'))
%%%%%%%%%ITU_AP8_AN3 %%%%2020 Appendix 8, Annex 3
wavelen_m=freq2wavelen(FreqMHz*10^6) %%%Wavelength in meters
g_max=ant_gain_dBi
capD=ant_diamter_m
%%%%%%%%
d_lambda=capD/wavelen_m
g1=2+15*log10(capD/wavelen_m)
phi_m=((20*wavelen_m)/capD)*sqrt(g_max-g1);
phi_r=15.85*((capD/wavelen_m)^(-0.6));
num_phi=length(phi_array);
array_gain=NaN(num_phi,2); %%%%%%1)Phi (Degrees), 2) Gain (dBi)
if ant_gain_dBi>=48 && d_lambda>=100 
    disp_TextArea_PastText(app,strcat('Part0 Grid Points:ITU Appendix 8-Annex 3:Option A'))
    %%%%Option A)    
    for i=1:1:num_phi
        temp_phi=phi_array(i);
        array_gain(i,1)=temp_phi;
        if temp_phi==0
            array_gain(i,2)=g_max;
        elseif 0<temp_phi && temp_phi<phi_m
            array_gain(i,2)=g_max-2.5*10^(-3)*(((capD/wavelen_m)*temp_phi)^2);
        elseif phi_m<=temp_phi && temp_phi<phi_r
            array_gain(i,2)=g1;            
        elseif phi_r<=temp_phi && temp_phi<48
             array_gain(i,2)=32-25*log10(temp_phi);
        elseif 48<=temp_phi && temp_phi<=180
            array_gain(i,2)=-10;
        else
            'Error: Array phi greater than 180'
            pause;
        end
    end
elseif ant_gain_dBi<48 && d_lambda<100 
    disp_TextArea_PastText(app,strcat('Part0 Grid Points:ITU Appendix 8-Annex 3:Option B'))
    %%%%Option B) 
    for i=1:1:num_phi
        temp_phi=phi_array(i);
        array_gain(i,1)=temp_phi;
        if temp_phi==0
            array_gain(i,2)=g_max;
        elseif 0<temp_phi && temp_phi<phi_m
            array_gain(i,2)=g_max-2.5*10^(-3)*(((capD/wavelen_m)*temp_phi)^2);
        elseif phi_m<=temp_phi && temp_phi<(100*(wavelen_m/capD))
            array_gain(i,2)=g1;            
        elseif (100*(wavelen_m/capD))<=temp_phi && temp_phi<48
             array_gain(i,2)=52-10*log10(capD/wavelen_m)-25*log10(temp_phi);
        elseif 48<=temp_phi && temp_phi<=180
            array_gain(i,2)=10-10*log10(capD/wavelen_m);
        else
            'Error: Array phi greater than 180'
            pause;
        end
    end
elseif ant_gain_dBi>=48 %%%%%%%No lamba requirement
    disp_TextArea_PastText(app,strcat('Part0 Grid Points:ITU Appendix 8-Annex 3:Option C'))
    %%%%Option A)
    for i=1:1:num_phi
        temp_phi=phi_array(i);
        array_gain(i,1)=temp_phi;
        if temp_phi==0
            array_gain(i,2)=g_max;
        elseif 0<temp_phi && temp_phi<phi_m
            array_gain(i,2)=g_max-2.5*10^(-3)*(((capD/wavelen_m)*temp_phi)^2);
        elseif phi_m<=temp_phi && temp_phi<phi_r
            array_gain(i,2)=g1;
        elseif phi_r<=temp_phi && temp_phi<48
            array_gain(i,2)=32-25*log10(temp_phi);
        elseif 48<=temp_phi && temp_phi<=180
            array_gain(i,2)=-10;
        else
            'Error: Array phi greater than 180'
            pause;
        end
    end
else
    disp_TextArea_PastText(app,strcat('Part0 Grid Points:ITU Appendix 8-Annex 3:Unknown Logic'))
    'Unknown logic'
    pause;
end



end