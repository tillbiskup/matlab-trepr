function [data,parameters] = trEPRFRload(filename,varargin)
% TREPRFRLOAD General importer routine for the different Freiburg file
% formats ("speksim").
%
% Usage: 
%   [data,parameters] = trEPRFRload(filename)
%
%   filename   - string
%                Name of file containing the original data
%
%   data       - vector
%
%   parameters - struct
%
% SEE ALSO: trEPRload

% Copyright (c) 2015, Till Biskup
% 2015-10-12

% Assign default output
data = [];
parameters = struct();

try
    % Parse input arguments using the inputParser functionality
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('filename',@ischar)
%     p.addParamValue('paperUnits','centimeters',@ischar);
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

switch getFileFormatNumber(fileContents)
    case 1
        [data,parameters] = readFormat1(fileContents);
    case 11
        [data,parameters] = readFormat11(fileContents);
    otherwise
        trEPRmsg('Apologies, not implemented yet...','warning');
        return;
end

end


function TF = correctFileFormat(fileContents)

TF = strncmpi(fileContents{1},'Source : transient',18);

end


function formatNo = getFileFormatNumber(fileContent)

formatNo = str2double(strtok(fileContent{4},' '));

end

function [data,parameters] = readFormat1(fileContents)

parameters = parseHeader(fileContents(2:5));

% Line 6 to end contain the actual data
data = str2num([fileContents{6:end}]); %#ok<ST2NM>

end


function [data,parameters] = readFormat11(fileContents)

parameters = parseHeader(fileContents([2:4,6]));

% Line 5 contains value pairs for factor and offset for x, Re(y), Im(y)
% This line is specific to formats 11-14
modifiers = sscanf(fileContents{5},'%f');

% Line 7 to end contain the actual ("compressed") data
% To "uncompress", add 999 to each value, multiply with the factor (3rd
% value in modifiers) and add offset (4th value in modifiers)
data = (str2num(reshape([fileContents{7:end}],4,[])')+999)...
    .*modifiers(3)+modifiers(4); %#ok<ST2NM>

end

function parameters = parseHeader(fileContents)

% Line 1 contains B0 and mwFreq value
parameters = parseB0andMWfreq(fileContents{1});

% Line 2 contains the user-specified comment
parameters.comment = fileContents{2};

% Line 3 contains format number, length, and info about x axis
parameters = getXaxisInfo(fileContents{3},parameters);

% Line 4 contains units of x and y axes
parameters = getUnits(fileContents{4},parameters);

end

function parameters = parseB0andMWfreq(fileContents,parameters)

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
else
    tokens = regexp(fileContents,...
        'B0 = ([0-9.]*)\s*(\w*),\s* mw = ([0-9.]*)\s*(\w*)',...
        'tokens');
    parameters.MWfrequency.value = ...
        str2double(tokens{1}{3});
    parameters.MWfrequency.unit = tokens{1}{4};
end
parameters.field.value = str2double(tokens{1}{1});
switch tokens{1}{2}
    case 'Gauss'
        parameters.field.unit = 'G';
    otherwise
        trEPRmsg(sprintf(...
            'Could not recognise unit for magnetic field: ''%s''',...
            tokens{1}{4}),'warning');
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
paramaeters.intensity.unit = strtrim(yunit);

end
