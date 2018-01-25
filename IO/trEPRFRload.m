function [data,varargout] = trEPRFRload(filename,varargin)
% TREPRFRLOAD General importer routine for the different Freiburg file
% formats ("speksim").
%
% Usage: 
%   [data] = trEPRFRload(filename,[<parameter>,<value>])
%   [data,warnings] = trEPRFRload(filename,[<parameter>,<value>])
%   [data,~,parameters] = trEPRFRload(filename,[<parameter>,<value>])
%
%   filename    - string
%                 Name of file containing the original data
%
%   data        - struct/vector
%                 Either a dataset (trEPR dataset structure, default)
%                 or a vector containing only the data
%
%   warnings    - cell (OPTIONAL)
%                 Warning messages
%
%   parameters  - struct (OPTIONAL)
%                 Hierarchical structure containing all parameters read
%                 from the file
%
% Optional parameter-value pairs can be specified as follows:
%
%   map2dataset - boolean (default: true)
%                 Whether to map data and parameters to trEPR dataset
%                 structure
%
% SEE ALSO: trEPRload

% Copyright (c) 2015-18, Till Biskup
% 2018-01-25

% Assign default output
data = [];

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename',@(x)ischar(x) && exist(x,'file'))
    p.addParamValue('map2dataset',true,@islogical);
    p.parse(filename,varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

fileContents = textFileRead(filename);

if ~correctFileFormat(fileContents)
    trEPRmsg('Incorrect file format (expects FR format)','warning');
    return;
end

fileFormatNo = getFileFormatNumber(fileContents);

switch fileFormatNo
    case 1
        [data,parameters] = readFormat1(fileContents);
    case 11
        [data,parameters] = readFormat11(fileContents);
    otherwise
        trEPRmsg('Apologies, not implemented yet...','warning');
        return;
end

parameters = addFileFormatInfo(parameters,filename,fileFormatNo);

if p.Results.map2dataset
    data = map2dataset(data,parameters);
end

% Assign "warnings" (empty cell) as first optional output
% Necessary to be compatible with current implementation of trEPRload
varargout{1} = {};
varargout{2} = parameters;

end

% --- Subfunctions (internal)

function TF = correctFileFormat(fileContents)

TF = strncmpi(fileContents{1},'Source : transient',18);

if ~TF
    TF = strncmpi(fileContents{1},'Source: Transient',17);
end

end


function formatNo = getFileFormatNumber(fileContent)

formatNo = str2double(strtok(fileContent{4},' '));

end

function [data,parameters] = readFormat1(fileContents)

parameters = parseHeader(fileContents(1:5));

% Line 6 to end contain the actual data
data = sscanf([fileContents{6:end}],'%f')';

end


function [data,parameters] = readFormat11(fileContents)

parameters = parseHeader(fileContents([1:4,6]));

% Line 5 contains value pairs for factor and offset for x, Re(y), Im(y)
% This line is specific to formats 11-14
modifiers = sscanf(fileContents{5},'%f');

% Line 7 to end contain the actual ("compressed") data
% To "uncompress", add 999 to each value, multiply with the factor (3rd
% value in modifiers) and add offset (4th value in modifiers)
data = ((str2num(reshape([fileContents{7:end}],4,[])')+999)...
    .*modifiers(3)+modifiers(4))'; %#ok<ST2NM>

end

function parameters = parseHeader(fileContents)

% Line 1 contains timestamp
parameters.timeStamp = parseTimestamp(fileContents{1});

% Line 2 contains B0 and mwFreq value
parameters = parseB0andMWfreq(fileContents{2},parameters);

% Line 3 contains the user-specified comment
parameters.comment = fileContents{3};

% Line 4 contains format number, length, and info about x axis
parameters = getXaxisInfo(fileContents{4},parameters);

% Line 5 contains units of x and y axes
parameters = getUnits(fileContents{5},parameters);

end


function isoTimeStamp = parseTimestamp(inputString)

isoTimeStamp = '';

inputString = inputString(strfind(inputString,'Time : ')+7:end);
if ~isempty(inputString)
    isoTimeStamp = datestr(datevec(inputString,'ddd mmm dd HH:MM:SS yyyy'),31);
end

end


function parameters = parseB0andMWfreq(fileContents,parameters)

% There is not always a "Gaussmeter" entry as second in this line...
if any(strfind(fileContents,'Gaussmeter'))
    tokens = regexp(fileContents{2},...
        ['B0 = ([0-9.]*)\s*(\w*),\s* B0\(Gaussmeter\) = '...
        '([0-9.-]*)\s*(\w*),\s* mw = ([0-9.]*)\s*(\w*)'],...
        'tokens');
    parameters.MWfrequency.value = ...
        str2double(tokens{1}{5});
    parameters.MWfrequency.unit = tokens{1}{6};
    parameters.gaussMeter.value = str2double(tokens{1}{3});
    switch tokens{1}{4}
        case 'Gauss'
            parameters.gaussMeter.unit = 'G';
        otherwise
            trEPRmsg(sprintf(...
                'Could not recognise unit for magnetic field: ''%s''',...
                tokens{1}{4}),'warning');
    end
elseif any(strfind(fileContents,' T'))
    tokens = regexp(fileContents,...
        ['B0 = ([0-9.]*)\s*(\w*)'],...
        'tokens');
else
    tokens = regexp(fileContents,...
        'B0 = ([0-9.]*)\s*(\w*),\s* mw = ([0-9.]*)\s*(\w*)',...
        'tokens');
    if ~isempty(tokens)
        parameters.MWfrequency.value = ...
            str2double(tokens{1}{3});
        parameters.MWfrequency.unit = tokens{1}{4};
    end
end

% Field parameters (from Hall probe) come always first.
parameters.field.value = str2double(tokens{1}{1});
switch tokens{1}{2}
    case 'Gauss'
        parameters.field.unit = 'G';
    case 'T'
        parameters.field.unit = 'mT';
        parameters.field.value = parameters.field.value * 1000;
    otherwise
        trEPRmsg(sprintf(...
            'Could not recognise unit for magnetic field: ''%s''',...
            tokens{1}{2}),'warning');
end

end

function parameters = getXaxisInfo(fileContents,parameters)

xAxisInfo = sscanf(fileContents,'%f');
parameters.time.length = xAxisInfo(2);
parameters.time.start = xAxisInfo(3);
parameters.time.stop = xAxisInfo(4);

end

function parameters = getUnits(fileContents,parameters)

[parameters.time.unit,yunit] = strtok(fileContents,' ');
parameters.intensity.unit = strtrim(yunit);

end

function parameters = addFileFormatInfo(parameters,filename,fileFormatNo)

parameters.file.name = filename;
parameters.file.format = sprintf('Speksim #%i',fileFormatNo);

end

function dataset = map2dataset(data,par)

dataset = trEPRdataStructure('structure');
dataset.data = data;
dataset.origdata = data;
if isfield(par,'MWfrequency')
    dataset.parameters.bridge.MWfrequency.value = par.MWfrequency.value;
    dataset.parameters.bridge.MWfrequency.unit = par.MWfrequency.unit;
else
    dataset.parameters.bridge.MWfrequency.value = [];
    dataset.parameters.bridge.MWfrequency.unit = 'GHz';
end
dataset.comment = {par.comment};
dataset.axes.data(1).values = ...
    linspace(par.time.start,par.time.stop,par.time.length);
dataset.axes.data(1).unit = par.time.unit;
dataset.axes.data(1).measure = 'time';
dataset.axes.data(2).values = par.field.value;
dataset.axes.data(2).unit = par.field.unit;
dataset.axes.data(2).measure = 'magnetic field';
dataset.axes.data(3).unit = par.intensity.unit;
dataset.axes.data(3).measure = 'intensity';
dataset.file = par.file;
dataset.parameters.transient.timeStamp{1} = par.timeStamp;

end
