function [table_oobe]=calc_oobe_7ghz_rev1(app,rev,oobeSeg,band_mhz,center_freq,cond_pwr_dBm)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% ======================= USER-ADJUSTABLE =======================
B=band_mhz;          % carrier bandwidth [MHz] [B]
fc=center_freq;         % carrier center [MHz]; channel edge = fc + B/2

%%%%%%%%%%%%%
P_TRX=cond_pwr_dBm;  % conducted power per transceiver [dBm]
%%%%P_TRX      = 37.5;  % conducted power per transceiver [dBm] (For the vairable EIRP)
N_TRX      = 128;   % transceivers, both polarizations
G_elem     = 6.4;   % element gain incl. losses [dBi]
N_elem_sub = 6;     % elements per subarray
MN         = 64;    % subarrays per polarization (4 x 16)

% % % % --- Correlation roll-off [x = |df|/B , rho], linear between rows ---
% % % % Breakpoints are normalized to B, so they rescale automatically if
% % % % the carrier bandwidth is changed.  rho = 0 beyond the last row.
rhoBP = [ 0     1     ;
          0.5   1     ;
          1.0   0.125 ;
          1.5   0.063 ;
          2.5   0     ];

%%%%%%%%%%%%%% --- Output grid ---
dfMax=B*2.5;%250;     % max offset [MHz]  [7600 end of antenna]
dfStep=1;        % grid step [MHz]

%%%%% ================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Derived quantities 
P_cond_tot   = P_TRX + 10*log10(N_TRX);        % total conducted [dBm]
P_inband_psd = P_cond_tot - 10*log10(B);       % in-channel PSD [dBm/MHz]
A_sub        = G_elem + 10*log10(N_elem_sub);  % subarray gain [dBi]


% Grid: uniform steps plus a sample just past every discontinuity
% (channel edge and each OOBE segment boundary) so the CSV integrates
% correctly across the steps.
epsF = 0.1;
bnd  = [fc + B/2; oobeSeg(:,1); oobeSeg(:,2)];
bnd  = bnd(isfinite(bnd) & bnd >= fc & bnd < fc + dfMax);
df   = unique([ (0:dfStep:dfMax).' ; bnd - fc + epsF ]);
f    = fc + df;

%%%%%%%%%% Correlation and TR 38.922 composite gain
rho = interp1(rhoBP(:,1), rhoBP(:,2), abs(df)/B, 'linear', 0);
G   = A_sub + 10*log10(1 + rho*(MN - 1));

%%%%%%%%%% Conducted PSD: in-channel block, then OOBE segments (last row wins)
Pc = nan(size(df));
Pc(df <= B/2) = P_inband_psd;
for k = 1:size(oobeSeg,1)
    idx = (df > B/2) & (f > oobeSeg(k,1)) & (f <= oobeSeg(k,2));
    Pc(idx) = oobeSeg(k,3);
end
% NaN persists only where f sits above the channel edge but below the
% first OOBE segment (carrier not flush with the band edge). That region
% is intra-license / ACLR territory, outside these OOBE commitments.

EIRP = Pc + G;   % boresight / peak-beam EIRP PSD [dBm/MHz]

%%%%%%%%%%% Write CSV
table_oobe = table(round(df,6), round(f,6), round(rho,4), round(G,2),round(Pc,2),round(EIRP,2));
table_oobe.Properties.VariableNames={'offset_from_center_MHz','freq_MHz','rho','composite_gain_dBi','conducted_PSD_dBm_per_MHz','EIRP_PSD_dBm_per_MHz'};
outFile = strcat('7ghz_bs_eirp_oobe_mask',num2str(rev),'.xlsx');
writetable(table_oobe, outFile);



%%%%%%%%%%%% Quick-look plot
figure;
hold on; 
grid on;
plot(df, EIRP, 'r-' , 'LineWidth', 1.8);
plot(df, Pc  , 'b--', 'LineWidth', 1.2);
plot(df, G   , 'g:' , 'LineWidth', 1.2);
xlabel(sprintf('Offset from f_c = %g MHz  [MHz]', fc));
ylabel('[dBm/MHz]  /  [dBi]');
legend('EIRP PSD (boresight)', 'Conducted PSD (total)','Composite gain', 'Location', 'northeast');
title(sprintf('7 GHz BS EIRP/OOBE mask  -  %g MHz carrier at %g-%g MHz',B, fc - B/2, fc + B/2));
xlim([0 dfMax]);
filename1=strcat('OOBE_',num2str(rev),'.png');
saveas(gcf,char(filename1))
pause(0.1)

end