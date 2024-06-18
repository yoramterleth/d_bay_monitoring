# SK d_bay_monitoring

various scripts looking at discharge on Sit Kusa. These were used for Terleth et al. (2024), available at https://doi.org/10.1017/jog.2024.38. 

- the somewhat unfortunate names for the individual scripts refer to the platform they pull data from. All these scripts build timeseries of various water surface properties within a user defined area, in our case in front of the S'it' Kus'a terminus. 

- the various earth engine scripts allow to export csv files. These can be downloaded from google drive and used with matlab. 

- the compile_and_plot.m script can be used to assemble the csvs from earth engine and plot them. It relies on a lot of helper functions, the ones that I generated myself are included in this repo and should at least compile the data. Other helpers for plotting etc. are not authored by me and not included here, but should be easy to find online if needed (or let me know and I can share the refs). 
