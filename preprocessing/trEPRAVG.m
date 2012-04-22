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
%              start     - scalar
%                          position in axis to start the averaging at
%              stop      - scalar
%                          position in axis to end the averaging at
%              label     - string, optional
%                          label for the averaged dataset
%
% avgData    - structure
%              contains both the averaged data (in avgData.data)
%              and all usual parameters of a dataset and the parameters
%              from the averaging in the history.parameters field

% (c) 2011-12, Till Biskup
% 2012-04-22

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)isstruct(x));
p.addRequired('parameters', @(x)isstruct(x));
p.parse(data,parameters);

try
    % As we inherit most of the fields from the original dataset, copy
    % original dataset completely in avgData
    avgData = data;
    
    % Perform averaging...
    switch parameters.dimension
        case 'x'
            avgData.data = ...
                mean(avgData.data(:,parameters.start:parameters.stop),2);
            % Calculate standard deviation
            avgData.avg.stdev = ...
                std(data.data(:,parameters.start:parameters.stop),0,2);
            avgData.axes.x.values = mean(...
                [avgData.axes.x.values(parameters.start) ...
                avgData.axes.x.values(parameters.stop)]);
        case 'y'
            avgData.data = ...
                mean(avgData.data(parameters.start:parameters.stop,:),1);
            % Calculate standard deviation
            avgData.avg.stdev = ...
                std(data.data(parameters.start:parameters.stop,:),0,2);
            avgData.axes.y.values = mean(...
                [avgData.axes.y.values(parameters.start) ...
                avgData.axes.y.values(parameters.stop)]);
        otherwise
            fprintf('\nUnknown dimension to average over: %s\n',...
                parameters.dimension);
            % As we do not overwrite the dataset, the original dataset will
            % be returned
            return;
    end
    
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
    throw(exception);
end

end