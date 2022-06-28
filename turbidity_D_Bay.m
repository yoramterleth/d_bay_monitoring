%% plot disenchantment bay turbidity values

%% load seismic and melt data 
times = [datetime(2020,08,15),datetime(2021,12,01) ]; 

% load seismic 
[seismic, t_seismic] = single_station_load('GHT_all_3_7Hz.mat', 'SW2',times,'tremor') ; 
seismic = movmean(seismic,24);

% load melt 
% [melt,melt_t] = load_melt(times); 
% melt= movmean(melt,24); 

% load turbidity series from band 7 
turbidityvalues20202022 = import_turbidity([pwd, '\turbidityvalues\turbidity_values_b7.csv']); 
values = turbidityvalues20202022.prop ; 

% delete nans(-9999) and suspicious full zeros 
values(values<0.01) = nan ; 
%values = values(2:end,16:end-2);
a = []; 

k = 1 ; 
while k <= length(values(1,:)) 
a = strcat(a,string(values(:,k))); 
k = k+1 ;
end 

%a2 = str2num(append(string(values(:,1)),string(values(:,2)),string(values(:,3)))); 


values = str2double(a) ; 
%values(values>2)=nan; 

% time boundaries form earth engine: 2020, 2021 
t1 = datetime(2020,01,02) ; % datetime(2020,02,15) , datetime(2021,02,15) ; 
t2 = datetime(2022,05,20) ; % is 05 20 for the b5 data ! % datetime(2020,11,14) , datetime(2021,09,19) ; 
t = t1:t2 ; 

% load band 5 turbidity values 
turbidityvalues20202022_b5 = import_turbidity([pwd, '\turbidityvalues\turbidity_values_b5.csv']); 
values_b5 = turbidityvalues20202022_b5.prop ; 

% delete nans(-9999) and suspicious full zeros 
values_b5(values_b5<0.01) = nan ; 
%values = values(2:end,16:end-2);
a_b5 = []; 

k = 1 ; 
while k <= length(values_b5(1,:)) 
a_b5 = strcat(a_b5,string(values_b5(:,k))); 
k = k+1 ;
end 

%a2 = str2num(append(string(values(:,1)),string(values(:,2)),string(values(:,3)))); 


values_b5 = str2double(a_b5) ; 

% time boundaries from earth engine 
t1_b5 = datetime(2020,01,02) ; % datetime(2020,02,15) , datetime(2021,02,15) ; 
t2_b5 = datetime(2022,05,20) ; % is 05 20 for the b5 data ! % datetime(2020,11,14) , datetime(2021,09,19) ; 
t_b5 = t1_b5:t2_b5 ; 
%load no_filter.mat

fig = figure ; 
subplot(2,1,1)
yyaxis left
%plot(t,no_filter,'-','color',[0.4660 0.6740 0.1880,0.3]),
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])

grid on 

%xlim([datetime(2021,04,01),datetime(2021,09,10)])


sp2 = subplot(2,1,2) ; 
set(sp2,'defaultAxesColorOrder',[rgb('green'); [0 0.4470 0.7410]]);
yyaxis left
%plot(t,no_filter,'-','color',[0.4660 0.6740 0.1880,0.3]),
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])

grid on 
ylabel('Average 555-565 nm radiance [W m^{-2} sr^{-1} μm^{-1}]')
%xlim([datetime(2021,04,01),datetime(2021,09,10)])

yyaxis right
plot(melt_t,melt./3,'-','linewidth',.7,'color',rgb('irish green'))
ylabel('surface runoff (m w.e. hr^{-1})')  
legend('cloud filtered data','running mean', 'modelled surface runoff')
ax = gca ; 
set(ax,'YColor', rgb('irish green') ); 

%% make a figure looking at the various rem sens timeseries together
fig2 = figure ;
yyaxis left 
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])
grid on 
ylabel('Average 615-625 nm radiance  (W m^{-2} sr^{-1} μm^{-1})')

yyaxis right
hold on 
plot(t_b5,values_b5,'-')
plot(t_b5, movmean(values_b5,7,'omitnan'),'linewidth',1.3)
ylabel('Average 555-565 nm radiance [W m^{-2} sr^{-1} μm^{-1}]')  
legend('cloud filtered data','running mean')

%%% conclusion: b5 and b7 are extremely similar. 

%% compare band 7 and the temperatures from sentinel 2 

% load sentinel 2 data 
[S2_dates] = importfile_S2dates([pwd, '\turbidityvalues\acquisition_dates_b11_long.csv']) ; 
t_S2 = S2_dates.date ; 
[S2_data] = importfile_S2_data([pwd, '\turbidityvalues\temp_values_b11_long.csv']) ; 
val_S2 = S2_data.prop ;
val_S2(val_S2<0.001) = nan ; 

figure 
yyaxis left 
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])
grid on 
ylabel('Average 615-625 nm radiance  [W m^{-2} sr^{-1} μm^{-1}]')
yyaxis right 
scatter(t_S2, val_S2)

%% compare band 7 and the sar data 

% load sentinel 1 sar vv polarized data 
[S1_dates] = importfile_S1dates([pwd, '\turbidityvalues\acquisition_dates_S1.csv']); 
[S1_data] = importfile_S1data([pwd, '\turbidityvalues\valuesS1.csv']);
t_S1 = S1_dates.date ;
val_S1 = S1_data.prop ;
%val_S1(val_S1<0.001) = nan ; 

figure 
yyaxis left 
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])
grid on 
ylabel('Average 615-625 nm radiance  (W m^{-2} sr^{-1} μm^{-1})')
yyaxis right 
hold on 
plot(t_S1, val_S1,'-','color',[0.9290 0.6940 0.1250,0.3])
plot(t_S1,movmean(val_S1,5,'omitnan'),'-','linewidth',1.3,'color',[0.8500 0.3250 0.0980])
ylabel('Sentinel-1 SAR GRD VV polarization (dB)')
%xlim([datetime(2021,04,01),datetime(2021,09,10)])




