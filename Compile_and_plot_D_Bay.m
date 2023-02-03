%% compiles the dbay data from earth engine and cobines it onto a plot.

%%  clean up 
close all
clear all
clc

%% set time scope
time_limits = [datetime(2017,01,01), datetime(2022,09,01)]; 

%% load data 


% MODIS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
M = importfile_MODISdates([pwd, '/turbidityvalues/MODIS_acquisition_dates_turb.csv']) ; 
D = importfile_MODISdata([pwd, '/turbidityvalues/MODIS_turb.csv']); 
M_t = M.year ; 
M_sr = D.sr ; 
M_sr(M_sr<0)= nan ; 
clear M D 

% S3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[S3_t, S3_r] = turbidity_compiler(); 

% S2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load sentinel 2 data 
[S2_dates] = importfile_S2dates([pwd, '\turbidityvalues\S2_acquisition_dates_turb.csv']) ; 
S2_t = S2_dates.date ; 
[S2_data] = importfile_S2_data([pwd, '\turbidityvalues\S2_turb_values.csv']) ; 
S2_sr = S2_data.prop ;
S2_sr(S2_sr<0.001) = nan ; 

% S1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load sentinel 1 sar vv polarized data 
[S1_dates] = importfile_S1dates([pwd, '\turbidityvalues\acquisition_dates_S12015.csv']); 
[S1_data] = importfile_S1data([pwd, '\turbidityvalues\valuesS1_2015.csv']);
S1_t = S1_dates.date ;
S1_bs = S1_data.prop ;

% MELT estimate %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% ( for Sit Kusa Project)

% load melt from stebfm 
% [melt,melt_t] = load_melt(time_limits,'SW2'); 



% seismic data (for sit Kusa project) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% load seismic 
%[seismic, t_seismic] = single_station_load('mat_file_all.mat', 'SW2',time_limits,'tremor') ; 


%% compile into a single csv for convenience 

t.seismic_t = convertStringsToChars(string(t_seismic',"yyyy-MM-dd HH:mm:ss"));
t.seismic = seismic;
t.melt_t = convertStringsToChars(string(melt_t,"yyyy-MM-dd HH:mm:ss")) ;
t.melt = melt';
t.modis_t = convertStringsToChars(string(M_t,"yyyy-MM-dd HH:mm:ss")) ; 
t.modis = M_sr ;
t.S1_t = convertStringsToChars(string(S1_t,"yyyy-MM-dd HH:mm:ss")) ;
t.S1 = S1_bs ;
t.S2_t = convertStringsToChars(string(S2_t,"yyyy-MM-dd HH:mm:ss")) ; 
t.S2 = S2_sr  ; 
t.S3_t = convertStringsToChars(string(S3_t,"yyyy-MM-dd HH:mm:ss")) ; 
t.S3 = S3_r ; 


struct2csv(t,'d_bay_UTIG.csv')



%% visualize

fig = figure ; 



% MODIS
ax1 = subplot(5,1,2) ; 
color1 = rgb('wheat') ; 
color2 = rgb('dirty orange'); 
scatter(M_t, M_sr, 'o','MarkerEdgeColor',color1,'MarkerFaceColor',color1,'MarkerEdgeAlpha',0.2,'MarkerFaceAlpha',0.2), hold on 
plot(M_t, movmean(M_sr,10,"omitnan"),'linewidth',1,'color',color2)
ylabel('surface reflectance')
set(ax1,'YColor',	color2)
ax1.YAxisLocation = 'right'; 
title('MODIS B1 - 620-670 nm','color',color2)
ax1.XAxis.Visible = 'off' ;
set(gca, 'box', 'off')
set(gca, "FontWeight", 'bold')
grid on
xlim(time_limits)

% patch delimitations 
xp = [datetime(2020,02,01),datetime(2021,08,13),datetime(2021,08,13),datetime(2020,02,01)] ; 
yp = [-50,-50,10,10] ; 
fa_patch = 0.1 ; 

% Melt 
ax1 = subplot(5,1,1) ; 
color2 = '#0072BD' ; 
plot(melt_t, melt,'linewidth',1,'color',color2), hold on 
patch(xp, yp,'red','FaceAlpha',fa_patch, 'EdgeColor', 'none')
ylabel({'Estimated surface', 'runoff (m^{3}hr^{-1})'},'fontweight','bold')
set(ax1,'YColor',	color2)
ax1.YAxisLocation = 'right'; 
title('STEBFM - surface runoff', 'color',color2)
ax1.XAxis.Visible = 'off' ;
set(gca, 'box', 'off')
set(gca, "FontWeight", 'bold')
grid on
xlim(time_limits)
ylim([min(melt), max(melt)])

% S2
ax2 = subplot(5,1,3) ; 
color1 = rgb('light green') ; 
color2 = rgb('jade green'); 
scatter(S2_t, S2_sr, 'o','MarkerEdgeColor',color1,'MarkerFaceColor',color1,'MarkerEdgeAlpha',0.2,'MarkerFaceAlpha',0.2), hold on 
plot(S2_t, movmean(S2_sr,10,"omitnan"),'linewidth',1,'color',color2)
patch(xp, yp,'red','FaceAlpha',fa_patch, 'EdgeColor', 'none')
ylabel('surface reflectance')
set(ax2,'YColor',	color2)
ax2.YAxisLocation = 'right'; 
title('Sentinel 2 MSI Band 4 - 655-675 nm','color',color2)
ax2.XAxis.Visible = 'off' ;
set(gca, 'box', 'off')
set(gca, "FontWeight", 'bold')
grid on
xlim(time_limits)
ylim([min(S2_sr), max(S2_sr)])

% S3
ax3 = subplot(5,1,4) ; 
color1 = rgb('light grey blue') ; 
color2 = rgb('grey blue'); 
scatter(S3_t, S3_r, 'o','MarkerEdgeColor',color1,'MarkerFaceColor',color1,'MarkerEdgeAlpha',0.2,'MarkerFaceAlpha',0.2), hold on 
plot(S3_t, movmean(S3_r,10,"omitnan"),'linewidth',1,'color',color2)
patch(xp, yp,'red','FaceAlpha',fa_patch, 'EdgeColor', 'none')
ylabel({'radiance'; '(W m^{-2} sr^{-1} μm^{-1})'})
set(ax3,'YColor',	color2)
ax3.YAxisLocation = 'right'; 
title('Sentinel-3 OLCI Band 7 - 615-625 nm','color',color2)
ax3.XAxis.Visible = 'off' ;
set(gca, 'box', 'off')
set(gca, "FontWeight", 'bold')
grid on
xlim(time_limits)
ylim([min(S3_r), max(S3_r)])

% S1 
ax4 = subplot(5,1,5) ; 
color1 = rgb('carolina blue') ; 
color2 = rgb('deep sky blue'); 
scatter(S1_t, S1_bs, 'o','MarkerEdgeColor',color1,'MarkerFaceColor',color1,'MarkerEdgeAlpha',0.2,'MarkerFaceAlpha',0.2), hold on 
plot(S1_t, movmean(S1_bs,10,"omitnan"),'linewidth',1,'color',color2)
patch(xp, yp,'red','FaceAlpha',fa_patch, 'EdgeColor', 'none')
ylabel({'VV polarization'; 'backscatter(dB)'})
set(ax4,'YColor',	color2)
ax4.YAxisLocation = 'right'; 
title('Sentinel-1 SAR GRD','color',color2)
% ax4.XAxis.Visible = 'off' ;
set(gca, 'box', 'off')
set(gca, "FontWeight", 'bold')
grid on
xlim(time_limits)
ylim([min(S1_bs), max(S1_bs)])

% AddLetters2Plots(fig, {'(a)','(b)','(c)','(d)','(e)'},'VShift', -0.04,'Location','NorthWest', 'Direction','TopDown')

fontsize(fig,18,"pixels")

%% 
