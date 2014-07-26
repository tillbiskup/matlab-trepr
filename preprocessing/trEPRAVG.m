function [avgData] = trEPRAVG(data,parameters)
% TREPRAVG Average over a range of points in dataset with the parameters
% provided in parameters.
%
% data       - struct 
%              dataset to perform the averaging for
% parameters - struct
%              parameter structure as collected by the trEPRgui_AVGwindow
%
%              dimension - string
%                          'x' or 'y'
%              start     - struct
%                          position in axis to start the averaging at
%                          fields: index, value, unit
%                          (Only "index" is necessary to perform the
%                          averaging.) 
%              stop      - struct
%                          position in axis to end the averaging at
%                          fields: index, value, unit
%                          (Only "index" is necessary to perform the
%                          averaging.) 
%              label     - string, optional
%                          label for the averaged dataset
%
% avgData    - structure
%              contains both the averaged data (in avgData.data)
%              and all usual parameters of a dataset and the parameters
%              from the averaging in the history.parameters field

% Copyright (c) 2011-14, Till Biskup
% 2014-07-26

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.addRequired('parameters', @(x)isstruct(x));
p.parse(data,parameters);

avgData = [];

% Check whether we have a twodimensional dataset
if min(size(data.data)) < 2
    return;
end

try
    % As we inherit most of the fields from the original dataset, copy
    % original dataset completely in avgData
    avgData = data;
    
    % Perform averaging...
    switch parameters.dimension
        case 'x'
            avgData.data = ...
                mean(avgData.data(:,...
                parameters.start.index:parameters.stop.index),2);
            % Adjust parameters
            parameters.start.value = ...
                avgData.axes.x.values(parameters.start.index);
            parameters.stop.value = ...
                avgData.axes.x.values(parameters.stop.index);
            parameters.start.unit = avgData.axes.x.unit;
            parameters.stop.unit = avgData.axes.x.unit;
            % Calculate standard deviation
            avgData.avg.stdev = ...
                std(data.data(:,...
                parameters.start.index:parameters.stop.index),0,2);
            % Adjust axis
            avgData.axes.x.values = mean(...
                [avgData.axes.x.values(parameters.start.index) ...
                avgData.axes.x.values(parameters.stop.index)]);
            % Fix problem with time axis in parameters
            avgData.parameters.transient.points = ...
                length(avgData.axes.x.values);
            % Reset slider position
            avgData.display.position.x = 1;
        case 'y'
            avgData.data = ...
                mean(avgData.data(...
                parameters.start.index:parameters.stop.index,:),1);
            % Adjust parameters
            parameters.start.value = ...
                avgData.axes.y.values(parameters.start.index);
            parameters.stop.value = ...
                avgData.axes.y.values(parameters.stop.index);
            parameters.start.unit = avgData.axes.y.unit;
            parameters.stop.unit = avgData.axes.y.unit;
            % Calculate standard deviation
            avgData.avg.stdev = ...
                std(data.data(...
                parameters.start.index:parameters.stop.index,:),0,2);
            % Adjust axis
            avgData.axes.y.values = mean(...
                [avgData.axes.y.values(parameters.start.index) ...
                avgData.axes.y.values(parameters.stop.index)]);
            % Reset slider position
            avgData.display.position.y = 1;
        otherwise
            fprintf('\nUnknown dimension to average over: %s\n',...
                parameters.dimension);
            % As we do not overwrite the dataset, the original dataset will
            % be returned
            return;
    end
    
    % Check whether something went wrong with averaging (NaN in avgData)
    if any(isnan(avgData.data))
        avgData = [];
        return;
    end

    % Set avg dimension
    avgData.avg.dimension = parameters.dimension;
    
    % Set label if applicable
    if isfield(parameters,'label')
        avgData.label = parameters.label;
    end
    
    % Write history
    history = struct();
    history.date = datestr(now,31);
    history.method = mfilename;
    % Get username of current user
    % In worst case, username is an empty string. So nothing should really
    % rely on it.
    % Windows style
    history.system.username = getenv('UserName');
    % Unix style
    if isempty(history.system.username)
        history.system.username = getenv('USER');
    end
    history.system.platform = platform;
    history.system.matlab = version;
    history.system.trEPR = trEPRinfo('version');
    history.parameters = parameters;
    history.info = '';
    
    avgData.history{end+1} = history;
    
catch exception
    trEPRexceptionHandling(exception);
end

end
