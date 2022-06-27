%% plot disenchantment bay turbidity values

%% load seismic and melt data 
times = [datetime(2020,08,15),datetime(2021,12,01) ]; 

% load seismic 
[seismic, t_seismic] = single_station_load('GHT_all_3_7Hz.mat', 'SW2',times,'tremor') ; 
seismic = movmean(seismic,24);
% load melt 
[melt,melt_t] = load_melt(times); 
melt= movmean(melt,24); 

% load turbidity series from band 7 
turbidityvalues20202022 = import_turbidity([pwd, '\turbidityvalues\turbidity_values_2020_2022.csv']); 
values = turbidityvalues20202022.prop ; 

% delete nans(-9999) and suspicious full zeros 
values(values<0.01) = nan ; 
%values = values(2:end,16:end-2);
a = []; 
% val =[]; 
% for j = 1:length(values(:,1))
% for i = 1:length(values(1,:))
%     val(j) = strcat(val,values(j,i))
% end 
% end
% val = strcat(values(1,1),values(1,2))
% val = append(values(:,1),values(:,2))
% val = join(values,2)
% val = textscan(values, '%f')
k = 1 ; 
while k <= length(values(1,:)) 
a = strcat(a,string(values(:,k))); 
k = k+1 ;
end 

%a2 = str2num(append(string(values(:,1)),string(values(:,2)),string(values(:,3)))); 


values = str2double(a) ; 
%values(values>2)=nan; 

% time boundaries form earth engine: 2020, 2021 
t1 = datetime(2020,01,01) ; % datetime(2020,02,15) , datetime(2021,02,15) ; 
t2 = datetime(2022,04,30) ; % is 05 20 for the b5 data ! % datetime(2020,11,14) , datetime(2021,09,19) ; 
t = t1:t2 ; 

%load no_filter.mat

fig = figure ; 
subplot(2,1,1)
yyaxis left
%plot(t,no_filter,'-','color',[0.4660 0.6740 0.1880,0.3]),
hold on 
plot(t,values,'-','color',[0.4940 0.1840 0.5560,0.3])
plot(t,movmean(values,7,'omitnan'),'-','linewidth',1.3,'color',[0 0.4470 0.7410])

grid on 
ylabel('Average 555-565 nm radiance [W m^{-2} sr^{-1} μm^{-1}]')
%xlim([datetime(2021,04,01),datetime(2021,09,10)])

yyaxis right
plot(t_seismic,seismic,'-','linewidth',.7)
ylabel('3-10Hz SW2 seismic power (dB rel. 1 m^{2} s^{-1})')  
legend('cloud filtered data','running mean', 'seismic power')

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
