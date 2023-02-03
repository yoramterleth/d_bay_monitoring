function acquisitiondatesS1 = importfile_S1dates(filename, dataLines)
%IMPORTFILE Import data from a text file
%  ACQUISITIONDATESS1 = IMPORTFILE(FILENAME) reads data from text file
%  FILENAME for the default selection.  Returns the data as a table.
%
%  ACQUISITIONDATESS1 = IMPORTFILE(FILE, DATALINES) reads data for the
%  specified row interval(s) of text file FILENAME. Specify DATALINES as
%  a positive scalar integer or a N-by-2 array of positive scalar
%  integers for dis-contiguous row intervals.
%
%  Example:
%  acquisitiondatesS1 = importfile("C:\Users\Yoram\OneDrive - University of Idaho\Desktop\PhD pos\TURNER\seismic\GHT_matlab\turbidityvalues\acquisition_dates_S1.csv", [2, Inf]);
%
%  See also READTABLE.
%
% Auto-generated by MATLAB on 28-Jun-2022 15:43:21

%% Input handling

% If dataLines is not specified, define defaults
if nargin < 2
    dataLines = [2, Inf];
end

%% Set up the Import Options and import the data
opts = delimitedTextImportOptions("NumVariables", 9);

% Specify range and delimiter
opts.DataLines = dataLines;
opts.Delimiter = "_";

% Specify column names and types
opts.VariableNames = ["systemindexpropgeo", "VarName2", "VarName3", "VarName4", "date", "VarName6", "VarName7", "VarName8", "VarName9"];
opts.VariableTypes = ["string", "categorical", "categorical", "double", "datetime", "datetime", "double", "string", "string"];

% Specify file level properties
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";

% Specify variable properties
opts = setvaropts(opts, ["systemindexpropgeo", "VarName8", "VarName9"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["systemindexpropgeo", "VarName2", "VarName3", "VarName8", "VarName9"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "date", "InputFormat", "yyyyMMdd'T'HHmmss");
opts = setvaropts(opts, "VarName6", "InputFormat", "yyyyMMdd'T'HHmmss");
opts = setvaropts(opts, "VarName4", "TrimNonNumeric", true);
opts = setvaropts(opts, "VarName4", "ThousandsSeparator", ",");

% Import the data
acquisitiondatesS1 = readtable(filename, opts);

end