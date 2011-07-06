function [accData,accReport] = trEPRACC(data,parameters)
% TREPRACC Accumulate datasets given as a cell array in data with the
% parameters provided in parameters.
%
% data       - cell array 
%              datasets to accumulate (at least two datasets)
% parameters - structure
%              parameter structure as collected by the trEPRgui_ACCwindow
%
% accData    - structure
%              contains both the accumulated data (in accData.data)
%              and all usual parameters of a dataset and the parameters
%              from the accumulation in the history.parameters field
% accReport  - cell array of strings
%              textual report of the accumulation process
%              used for the trEPRgui_ACCwindow
%              a copy is copied to the history.info field

% (c) 2011, Till Biskup
% 2011-07-04

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)iscell(x));
p.addRequired('parameters', @(x)isstruct(x));
p.parse(data,parameters);

try
    if (length(data) < 2)
        accData = [];
        accReport = {...
            'Accumulation FAILED!'...
            ' '...
            'PROBLEM:  Too few datasets.'...
            'SOLUTION: Try to accumulate at least two datasets.'...
            };
        return;
    end
    
    % First step: Check whether axes overlap, and if not, return with error
    % Get axes limits (and other things, minimising for loops) for datasets
    xMin = zeros(1,length(data));
    xMax = zeros(1,length(data));
    yMin = zeros(1,length(data));
    yMax = zeros(1,length(data));
    xStep = zeros(1,length(data));
    yStep = zeros(1,length(data));
    accLabels = cell(1,length(data));
    for k=1:length(data)
        xMin(k) = data{k}.axes.x.values(1);
        xMax(k) = data{k}.axes.x.values(end);
        yMin(k) = data{k}.axes.y.values(1);
        yMax(k) = data{k}.axes.y.values(end);
        xStep(k) = data{k}.axes.x.values(end)-data{k}.axes.x.values(end-1);
        yStep(k) = data{k}.axes.y.values(2)-data{k}.axes.y.values(1);
        % Helping Matlab not making silly rounding mistakes, or at least
        % make them somewhat equal
        xStep(k) = round(xStep(k)*1e12)/1e12;
        yStep(k) = round(yStep(k)*1e12)/1e12;
        accLabels{k} = data{k}.label;
    end
    
    if ((max(xMin) >= min(xMax)) || (max(yMin) >= min(yMax)))
        accData = [];
        accReport = {...
            'Accumulation FAILED!'...
            ' '...
            'PROBLEM:  Axes not overlapping.'...
            'SOLUTION: Check axis dimensions of datasets involved.'...
            };
        return;
    end
    
    % TODO: Sanitise parameters structure (look for necessary fields and
    % values and if not provided, set default values)
    
    % Predefine fields for accData
    accData = struct();
    % data - accumulated data
    accData.data = [];
    % header - ...
    accData.header = cell(0);
    % axes - struct
    accData.axes = struct();
    % label - string
    accData.label = parameters.label;
    % filename - empty string
    accData.filename = '';
    % parameters - struct, contains experimental parameters
    accData.parameters = struct();
    % display - struct
    accData.display = struct();
    accData.display.position.x = 1;
    accData.display.position.y = 1;
    accData.display.displacement.x = 0;
    accData.display.displacement.y = 0;
    accData.display.displacement.z = 0;
    accData.display.scaling.x = 1;
    accData.display.scaling.y = 1;
    accData.display.scaling.z = 1;
    accData.display.smoothing.x.value = 1;
    accData.display.smoothing.y.value = 1;
    % line - struct
    accData.line = struct();
    % history - cell array of structs
    accData.history = cell(0);
    
    % Set fields that can be taken from master dataset
    accData.line = data{parameters.datasets == parameters.master}.line;
    accData.parameters = ...
        data{parameters.datasets == parameters.master}.parameters;
    accData.display.position = ...
        data{parameters.datasets == parameters.master}.display.position;
    
    % Check for axes steppings and handle interpolation accordingly, or,
    % for the time being, complain that interpolation is not supported yet.
    if ((min(xStep) ~= max(xStep)) || (min(yStep) ~= max(yStep)))
        accData = [];
        accReport = {...
            'Accumulation FAILED!'...
            ' '...
            'PROBLEM:  Interpolation not yet implemented.'...
            'SOLUTION: File bug report.'...
            };
        return;
    end
    % TODO: For the interpolation, account for master dataset
    
    % Cut data dimensions to respective size
    % TODO: Account for master dataset
    xLimits = [ max(xMin) min(xMax) ];
    yLimits = [ max(yMin) min(yMax) ];

    % Make axes of final accumulated dataset
    accData.axes.x.values = linspace(xLimits(1),xLimits(2),...
        int32((xLimits(2)-xLimits(1))/xStep(1))+1);
    accData.axes.x.measure = ...
        data{parameters.datasets == parameters.master}.axes.x.measure;
    accData.axes.x.unit = ...
        data{parameters.datasets == parameters.master}.axes.x.unit;
    accData.axes.y.values = linspace(yLimits(1),yLimits(2),...
        int32((yLimits(2)-yLimits(1))/yStep(1))+1);
    accData.axes.y.measure = ...
        data{parameters.datasets == parameters.master}.axes.y.measure;
    accData.axes.y.unit = ...
        data{parameters.datasets == parameters.master}.axes.y.unit;
    
    % Preallocate accData.data space 
    % (Here, make it a 3D matrix. Makes life much more easy for summing)
    accData.data = zeros(...
        length(accData.axes.y.values),...
        length(accData.axes.x.values),...
        length(data));
    
    for k=1:length(data)
        % For now, make it easy, first get the indices, then cut the matrix
        xmini = find(data{k}.axes.x.values==xLimits(1));
        xmaxi = find(data{k}.axes.x.values==xLimits(2));
        ymini = find(data{k}.axes.y.values==yLimits(1));
        ymaxi = find(data{k}.axes.y.values==yLimits(2));
        accData.data(:,:,k) = data{k}.data(ymini:ymaxi,xmini:xmaxi);
    end
    
    switch parameters.method
        case 'cumulative'
            accData.data = sum(accData.data,3)/length(data);
        case 'weighted'
            accData = [];
            accReport = {...
                'Accumulation FAILED!'...
                ' '...
                'PROBLEM:  Accumulation method "weighted" not supported yet.'...
                'SOLUTION: File bug report.'...
                };
            return;
        otherwise
            accData = [];
            accReport = {...
                'Accumulation FAILED!'...
                ' '...
                sprintf('PROBLEM:  Unknown accumulation method "%s".',...
                parameters.method)...
                'SOLUTION: File bug report.'...
                };
            return;
    end
    
    % Tell user that accumulation succeeded and (finally) give details
    % accReport will end in being a cell array
    % The maximum line length for accReport is 56 characters (in Linux)
    accReport = {...
        sprintf('Accumulation of %i datasets successful',length(data))...
        ' '...
        'Label for accumulated dataset:'...
        parameters.label...
        };
    accReport = [...
        accReport ...
        {...
        ' '...
        'The following datasets have been accumulated:'...
        }...
        accLabels ...
        {...
        ' '...
        'Master dataset:'...
        data{parameters.datasets == parameters.master}.label...
        ' '...
        'Dimensions of accumulated dataset:'...
        sprintf('size (x,y): %i x %i',fliplr(size(accData.data)))...
        sprintf('x axis:     %s : %s : %s',...
        num2str(xLimits(1)),num2str(xStep(1)),num2str(xLimits(2)))...
        sprintf('y axis:     %s : %s : %s',...
        num2str(yLimits(1)),num2str(yStep(1)),num2str(yLimits(2)))...
        ' '...
        sprintf('Accumulation method: %s',parameters.method)...
        }...
        ];
    if (strcmpi(parameters.method,'weighted'))
        accReport = [...
            accReport ...
            {...
            ' '...
            'Weights '...
            }...
            ];
    end
    accReport = [...
        accReport ...
        {...
        ' '...
        sprintf('Interpolation method: %s',parameters.interpolation)...
        }...
        ];
        
    % Write history
    history = struct();
    history.date = datestr(now,31);
    history.method = mfilename;
    
    % Fiddle around with parameters structure, as it gets to hold all
    % information about the accumulated datasets as well
    history.parameters = parameters;
    history.parameters = rmfield(history.parameters,'datasets');
    for k=1:length(data)
        % Assemble structure that holds all necessary information about the
        % accumulated datasets
        history.parameters.datasets{k}.axes = data{k}.axes;
        history.parameters.datasets{k}.label = data{k}.label;
        history.parameters.datasets{k}.filename = data{k}.filename;
        history.parameters.datasets{k}.header = data{k}.header;
        history.parameters.datasets{k}.history = data{k}.history;
    end
    
    % Assign complete accReport to info field of history
    history.info = accReport;
    
    % Assign history to dataset of accumulated data
    accData.history = cell(0);
    accData.history{1} = history;
    
catch exception
    throw(exception);
end

end