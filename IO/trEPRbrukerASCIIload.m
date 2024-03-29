function [ data, warnings ] = trEPRbrukerASCIIload(filename)
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

% Copyright (c) 2011-15, Till Biskup
% 2015-10-17

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('filename', @(x)ischar(x));
p.parse(filename);

    
% Preassign values to the data struct
data = trEPRdataStructure;
warnings = cell(0);

try
    % If there is no filename specified or filename does not exist, return
    if isempty(filename) && ~exist(filename,'file')
        data = struct();
        warnings{end+1} = struct(...
            'identifier','trEPRbrukerASCIIload:nofile',...
            'message','No filename or file does not exist'...
            );
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
        warnings{end+1} = struct(...
            'identifier','trEPRbrukerASCIIload:fileformat',...
            'message',...
            'File doesn''t look like a Bruker Xepr TREPR ASCII file'...
            );
        return;
    end
    
    % Find the size of a time trace, therefore, lookup the positions for
    % the maximum value in the second column, being the time axis
    a = find(rawData.data(:,2)==max(rawData.data(:,2)));
    
    % Now, reshape the real data, being in column four, using the first
    % value of a as size
    data.data = reshape(rawData.data(:,4),a(1),[])';
    
    % Creating x axis (time)
    data.axes.data(1).values = rawData.data(1:a(1),2);
    data.axes.data(1).measure = lower(tokens{2}{1});
    data.axes.data(1).unit = tokens{3}{1};
    
    % Creating y axis (field)
    data.axes.data(2).values = rawData.data(1:a(1):end,3);
    if strcmpi(tokens{4}{1},'Field')
        data.axes.data(2).measure = 'magnetic field';
    else
        data.axes.data(1).measure = lower(tokens{4}{1});
    end
    data.axes.data(2).unit = tokens{5}{1};
    
    % Creating z axis (field)
    data.axes.data(3).measure = lower(tokens{6}{1});
    
    % Write additional fields
    data.file.name = filename;
    data.file.format = 'BrukerASCII';
    data.label = filename;
    data.header = rawData.textdata;
    
    % Write parameters structure, partly filled with values
    % Details of the structure can be found at the toolbox homepage, look
    % for description of the trEPRload return argument format
    data.parameters.runs = 1;
    data.parameters.field.start.value = data.axes.data(2).values(1);
    data.parameters.field.stop.value = data.axes.data(2).values(end);
    data.parameters.field.step.value = ...
        data.axes.data(2).values(2)-data.axes.data(2).values(1);
    data.parameters.field.start.unit = data.axes.data(1).measure;
    data.parameters.field.stop.unit = data.axes.data(1).measure;
    data.parameters.field.step.unit = data.axes.data(1).measure;
    data.parameters.transient.points = length(data.axes.data(1).values);
    data.parameters.transient.length.value = ...
        data.axes.data(1).values(end)-data.axes.data(1).values(1);
    data.parameters.transient.length.unit = data.axes.data(1).unit;
    
    % Handle origdata
    data.origdata = data.data;
    data.axes.origdata = data.axes.data;
catch exception
    throw(exception);
end

end
