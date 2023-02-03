function valuesS1 = importfile_S1data(filename, dataLines)
%IMPORTFILE Import data from a text file
%  VALUESS1 = IMPORTFILE(FILENAME) reads data from text file FILENAME
%  for the default selection.  Returns the data as a table.
%
%  VALUESS1 = IMPORTFILE(FILE, DATALINES) reads data for the specified
%  row interval(s) of text file FILENAME. Specify DATALINES as a
%  positive scalar integer or a N-by-2 array of positive scalar integers
%  for dis-contiguous row intervals.
%
%  Example:
%  valuesS1 = importfile("C:\Users\Yoram\OneDrive - University of Idaho\Desktop\PhD pos\TURNER\seismic\GHT_matlab\turbidityvalues\valuesS1.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 28-Jun-2022 15:45:21

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
opts.VariableNames = ["systemindex", "prop", "geo"];
opts.VariableTypes = ["double", "double", "categorical"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, "geo", "EmptyFieldRule", "auto");

% Import the data
valuesS1 = readtable(filename, opts);

end