function MODISacquisitiondatesturb = importfile_MODISdates(filename, dataLines)
%IMPORTFILE Import data from a text file
%  MODISACQUISITIONDATESTURB = IMPORTFILE(FILENAME) reads data from text
%  file FILENAME for the default selection.  Returns the data as a table.
%
%  MODISACQUISITIONDATESTURB = IMPORTFILE(FILE, DATALINES) reads data
%  for the specified row interval(s) of text file FILENAME. Specify
%  DATALINES as a positive scalar integer or a N-by-2 array of positive
%  scalar integers for dis-contiguous row intervals.
%
%  Example:
%  MODISacquisitiondatesturb = importfile("C:\Users\Yoram\OneDrive - University of Idaho\Desktop\PhD pos\TURNER\seismic\GHT_matlab\turbidityvalues\MODIS_acquisition_dates_turb.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 04-Nov-2022 11:51:29

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 3);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = ",";

% Specify column names and types
opts.VariableNames = ["systemindex", "year", "month"];
opts.VariableTypes = ["double", "datetime", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "month", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "year", "InputFormat", "yyyy_MM_dd");

% Import the data
MODISacquisitiondatesturb = readtable(filename, opts);

end