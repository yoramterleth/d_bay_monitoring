%% compile the two turbidity records 
function [turb_time, turb_values] = turbidity_compiler() 
% there seems to be a gap in the data formats, which messed with gee. So re
% connnect two records of turbidity. 

%% band 7 
%
%% load turbidity series from 2016-2018
turbidityvalues20162018 = import_turbidity([pwd, '\turbidityvalues\turbidity_values_b7_2016_2018.csv']); 
values = turbidityvalues20162018.prop ; 

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


values16_18 = str2double(a) ; 
%values(values>2)=nan; 

% time boundaries form earth engine: 2020, 2021 
t2016 = datetime(2016,09,02) ; % datetime(2020,02,15) , datetime(2021,02,15) ; 
t2018 = datetime(2018,05,01) ; % is 05 20 for the b5 data ! % datetime(2020,11,14) , datetime(2021,09,19) ; 
t16_18 = t2016:t2018 ; 

%% load turbidity series 2018-2022
turbidityvalues20182022 = import_turbidity([pwd, '\turbidityvalues\turbidity_values_b7_2018.csv']); 
values = turbidityvalues20182022.prop ; 

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


values18_22 = str2double(a) ; 
%values(values>2)=nan; 

% time boundaries form earth engine: 2020, 2021 
t1 = datetime(2018,09,02) ; % datetime(2020,02,15) , datetime(2021,02,15) ; 
t2 = datetime(2022,06,20) ; % is 05 20 for the b5 data ! % datetime(2020,11,14) , datetime(2021,09,19) ; 
t18_22 = t1:t2 ; 

%% add nans in the gap, for convenience 
t_nan = t2018+days(1):t1-days(1) ;
val_nan = nan(length(t_nan),1) ; 
%% merge the two 
turb_time = [t16_18';t_nan'; t18_22']; 
turb_values = [values16_18 ;val_nan; values18_22] ; 

end 