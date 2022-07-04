%% megaplot 

close all 
clear all
clc

%% dates 
times = [datetime(2020,09,15),datetime(2021,09,30) ]; 

%% load data 

% load seismic 
[seismic, t_seismic] = single_station_load('GHT_all_3_7Hz.mat', 'SE7',times,'tremor') ; 

% load GNSS 
GNSS_wl = 6 ; % * 1 hour 

G11 = importGNSS([pwd,'/GNSSfiles/G11_2108_hourly_avg.csv']) ; 
G12 = importGNSS([pwd,'/GNSSfiles/G12_2008_hourly_avg.csv']) ; 
G14 = importGNSS([pwd,'/GNSSfiles/G14_2008_hourly_avg.csv']) ; 
G15 = importGNSS([pwd,'/GNSSfiles/G15_2106_hourly_avg.csv']) ; 

g12 = movmean(G12.speed_md,GNSS_wl) ; 
g12_t = G12.datetime ; 


g11 =  movmean(G11.speed_md,GNSS_wl) ; 
g11_t = G11.datetime ; 

g15 =  movmean(G15.speed_md,GNSS_wl) ; 
g15_t = G15.datetime ; 



% load melt 
[melt,melt_t] = load_melt(times); 

melt= movmean(melt,1); 


%% make figure 
% set liniwidth for all 
lw = 1.2 ; 

fig1 = figure ; 
mlt = subplot(4,1,1) ; 
    plot(melt_t,melt, 'linewidth',lw) ; 
    xlim([times(1),times(2)]);
    ylabel('Estimated surface runoff (m^{3})','fontweight','bold')
    %set(mlt, 'XTickLabel',[], 'xtick', []);
    set(mlt, 'box','off')
    set(mlt,'fontweight','bold')
    %mlt.XAxis.Visible='off' ;
    mlt.XAxisLocation = 'top' ; 
    
    ylim([0, 0.125])

  
    
seis = subplot(4,1,2) ; 
        plot(t_seismic, seismic, 'linewidth',lw,'color',rgb('pumpkin'))
    xlim([times(1),times(2)]);
    ylabel({'SE7 seismic power'; '3-10 Hz (dB rel. 1 m^{2}s^{-1})'},'fontweight','bold')
    set(seis, 'XTickLabel',[], 'xtick', []);
    set(seis,'fontweight','bold')
    set(seis, 'box','off')
    seis.XAxis.Visible='off' ;
    set(seis,'YColor',	rgb('pumpkin'))
    seis.YAxisLocation = 'right'; 
    ylim([-160, -140])

GNSS = subplot(4,1,3) ; 
    plot(g11_t, g11, 'linewidth',lw,'color',rgb('grass green')), hold on 
    plot(g15_t, g15, 'linewidth',lw,'color',rgb('blue green'))
    plot(g12_t, g12, 'linewidth',lw,'color',rgb('olive drab'))
    legend('G11','G15','G12')
    set(GNSS, 'XTickLabel',[], 'xtick', []);
    xlim([times(1),times(2)]);
    ylabel('GNSS velocity (m day^{-1})','fontweight','bold')
    set(GNSS,'YColor',	rgb('dull green'))
    set(GNSS,'fontweight','bold')
    GNSS.YAxisLocation = 'left'; 
    set(GNSS, 'box','off')
    ylim([0, 28])
    GNSS.XAxis.Visible='off' ; 

LAGS = subplot(4,1,4) ; 
dists =[0, 1630, 1380, 6362 , 9440, 8320 , 14000] ; 
lgs = load('lagsout.mat') ; 
    pcolor(lgs.dates, dists(2:end), -diff(lgs.LAGS)), shading flat 
    cmap = flipud(abs(cbrewer('div','RdBu',128,'spline')));
    cmap(cmap>1)=1; 
    colormap(LAGS,cmap)
    %colormap(LAGS,plasma(256))
    axis ij
    yticks([0;1380;1630;6362;8320;9440;14000]) ; 
    yticklabels({'SE15',[],'SW14','SE9','SE7','SW7','SW2'});
    set(LAGS, 'box','off')
    set(LAGS,'YColor',	[cmap(110,:)])
    set(LAGS,'fontweight','bold')
    LAGS.YAxisLocation = 'left'; 
    xlim([times(1),times(2)]);
    set(LAGS, 'XTickLabel',[], 'xtick', []);
    LAGS.XAxis.Visible='off' ;
    ylim([0,14000]); 
    
    
% cb=colorbar;
% ylabel(cb,'lag between adjacent stations (hours)'),
% set(cb,'YColor',	[cmap(110,:)])


    

%  %% make figure 
% % set liniwidth for all 
% lw = 1.5 ; 
% 
% fig1 = tiledlayout(4,1); 
% 
% mlt = nexttile; 
%     plot(melt_t,melt, 'linewidth',lw) ; 
%     xlim([times(1),times(2)]);
%     ylabel('Estimated surface runoff (m^{3})','fontweight','bold')
%     set(mlt, 'XTickLabel',[], 'xtick', []);
%     set(mlt, 'box','off')
%     set(mlt,'fontweight','bold')
%     mlt.XAxis.Visible='off' ;
%     set(mlt,'YColor','#0072BD')
% 
%   
%     
% seis = nexttile; 
%         plot(t_seismic, seismic, 'linewidth',lw,'color',rgb('pumpkin'))
%     xlim([times(1),times(2)]);
%     ylabel('SE7 seismic power 3-10 Hz (dB rel. 1 m^{2}s^{-1})','fontweight','bold')
%     set(seis, 'XTickLabel',[], 'xtick', []);
%     set(seis,'fontweight','bold')
%     set(seis, 'box','off')
%     seis.XAxis.Visible='off' ;
%     set(seis,'YColor',	rgb('pumpkin'))
%     seis.YAxisLocation = 'right'; 
% 
% GNSS = nexttile ; 
%     plot(g11_t, g11, 'linewidth',lw,'color',rgb('grass green')), hold on 
%     plot(g15_t, g15, 'linewidth',lw,'color',rgb('blue green'))
%     plot(g12_t, g12, 'linewidth',lw,'color',rgb('olive drab'))
%     legend('G11','G15','G12')
%     
%     xlim([times(1),times(2)]);
%     ylabel('GNSS velocity (m day^{-1})','fontweight','bold')
%     set(GNSS,'YColor',	rgb('dull green'))
%     set(GNSS,'fontweight','bold')
%     GNSS.YAxisLocation = 'left'; 
%     set(GNSS, 'box','off')
% 
% LAGS = nexttile
% dists =[0, 1630, 1380, 6362 , 9440, 8320 , 14000] ; 
% lgs = load('lagsout.mat') ; 
%     pcolor(lgs.dates, dists(2:end), diff(lgs.LAGS)), shading flat 
%     
% 
% fig1.Padding = 'none';
% fig1.TileSpacing = 'none';

%% make figure 

% fig1 = figure ; 
% t = tiledlayout(4, 1) ; 
% t.TileSpacing = 'none';
% t.Padding = 'loose';
% 
% mlt = nexttile ; 
%     plot(melt_t,melt, 'linewidth',2)
%     xlim([times(1),times(2)]);
%     ylabel('Estimated surface Runoff (m^{3})')
%     set(mlt, 'XTickLabel',[], 'xtick', []);
%     set(mlt, 'box','off')
%     
% seis = nexttile ;
%     plot(t_seismic, seismic)
%     
% 
% han2 = axes(fig1,'visible','off'); 
% han2.YLabel.Visible = 'on';
% ylab = ylabel(han2,'Y Axis Lable');
% set(han2, 'FontSize', 14)
% ylab.Position(1) = -0.1; 
% ylab.Position(2) = 0.5;


