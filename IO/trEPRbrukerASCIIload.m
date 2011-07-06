function [ data, warning ] = trEPRbrukerASCIIload(filename)
% TREPRBRUKERASCIILOAD Read Bruker Xepr ASCII export of transient spectra
%
% Usage
%   data = trEPRbrukerASCIIload(filename)
%   [data,warning] = trEPRbrukerASCIIload(filename)
%
% filename - string
%            name of a valid filename (of a ASCII export of Bruker Xepr
%            transient EPR data)
% data     - struct
%            structure containing data and additional fields
%
% warning  - cell array of strings
%            empty if there are no warnings
%
% If no data could be loaded, data is an empty struct.
% In such case, warning may hold some further information what happened.

% (c) 2011, Till Biskup
% 2011-07-06

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename);

try
    % If there is no filename specified or filename does not exist, return
    if isempty(filename) && ~exist(filename,'file')
        data = struct();
        warning = {'No filename or file does not exist'};
        return;
    end
    % Import raw data, using Matlab's "importdata"
    rawData = importdata(filename);
    
    % Some basic test whether this is the right format, using the
    % rawData.textdata field and some strcmp stuff 
    [tokens] = regexp(rawData.textdata{1},'\s*(\w+)\s*','tokens');
    if ~(strcmp(tokens{1},'index') && strcmp(tokens{2},'Time') && ...
            strcmp(tokens{4},'Field') && strcmp(tokens{6},'Intensity'))
        disp('Hmm... doesn''t look like a Bruker Xepr TREPR ASCII file');
        data = struct();
        warning = {...
            'Wrong file format'...
            'File doesn''t look like a Bruker Xepr TREPR ASCII file'...
            };
        return;
    end
    
    % Find the size of a time trace, therefore, lookup the positions for
    % the maximum value in the second column, being the time axis
    a = find(rawData.data(:,2)==max(rawData.data(:,2)));
    
    % Now, reshape the real data, being in column four, using the first
    % value of a as size
    data.data = reshape(rawData.data(:,4),a(1),[])';
    
    % Creating x axis (time)
    data.axes.x.values = rawData.data(1:a(1),2);
    data.axes.x.measure = 'time';
    data.axes.x.unit = tokens{3}{1};
    
    % Creating y axis (field)
    data.axes.y.values = rawData.data(1:a(1):end,3);
    data.axes.y.measure = 'field';
    data.axes.y.unit = tokens{5}{1};
    
    % Write additional fields
    data.filename = filename;
    data.label = filename;
    data.header = rawData.textdata;
    
    % Write parameters structure, partly filled with values
    % Details of the structure can be found at the toolbox homepage, look
    % for description of the trEPRload return argument format
    data.parameters.runs = 1;
    data.parameters.field.start = data.axes.y.values(1);
    data.parameters.field.stop = data.axes.y.values(end);
    data.parameters.field.step = ...
        data.axes.y.values(2)-data.axes.y.values(1);
    data.parameters.recorder.sensitivity.value = [];
    data.parameters.recorder.sensitivity.unit = '';
    data.parameters.recorder.averages = [];
    data.parameters.recorder.timeBase = [];
    data.parameters.transient.points = length(data.axes.x.values);
    data.parameters.transient.triggerPosition = [];
    data.parameters.transient.length = ...
        data.axes.x.values(end)-data.axes.x.values(1);
    data.parameters.bridge.MWfrequency = [];
    data.parameters.bridge.attenuation = [];
    data.parameters.temperature = [];
    data.parameters.laser.wavelength = [];
    data.parameters.laser.repetitionRate = [];
    
    % Assinging empty cell array to warning
    warning = cell(0);
catch exception
    throw(exception);
end

end