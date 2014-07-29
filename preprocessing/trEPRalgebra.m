function [resdata,warnings] = trEPRalgebra(data,operation,varargin)
% TREPRALGEBRA Perform algebraic operation on two given datasets.
%
% Usage
%   data = trEPRalgebra(data,operation);
%   [data,warnings] = trEPRalgebra(data,operation);
%
% data       - cell array
%              Datasets conforming to the trEPR toolbox data format
%
% operation  - string
%              Operation to be performed on the two datasets.
%              Currently '+' or '-' and the pendants 'add' and 'subtract',
%              and 'scale'
%
% data       - struct
%              Dataset resulting from the algebraic operation.
%
% warnings   - string
%              Empty if everything went well, otherwise contains message.

% Copyright (c) 2013-14, Till Biskup
% 2014-07-27

warnings = '';
resdata = [];

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % Include function in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('data', @(x)iscell(x));
    p.addRequired('operation', @(x)ischar(x) || isstruct(x));
    p.parse(data,operation);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

if ischar(operation)
    parameters.operation = operation;
else
    parameters = operation;
end

try
    if (length(data) ~= 2) && ~strcmpi(parameters.operation,'scaling')
        warnings = 'Other than two datasets, therefore no operation done';
        return;
    end
    
    % Convert operations
    if any(strfind(lower(parameters.operation),'add')) || ...
            strcmpi(parameters.operation,'+')
        parameters.operation = 'addition';
    end
    if any(strfind(lower(parameters.operation),'sub')) || ...
            strcmpi(parameters.operation,'-')
        parameters.operation = 'subtraction';
    end
    
    
    % Perform all (temporary) operations such as displacement, scaling,
    % smoothing, normalisation
    
    % Special case with normalisation: Exists only inside the GUI
    mainWindow = trEPRguiGetWindowHandle();
    if ~isempty(mainWindow)
        ad = getappdata(mainWindow);
        normPar = ad.control.axis.normalisation;
        normPar.displayType = ad.control.axis.displayType;
    end
    
    for k=1:length(data)
        data{k} = trEPRdatasetApplyDisplacement(data{k});
        data{k} = trEPRdatasetApplyScaling(data{k});
        data{k} = trEPRdatasetApplySmoothing(data{k});
        if exist('ad','var')
            data{k} = trEPRdatasetApplyNormalisation(data{k},normPar);
        end
    end
    
    % Assign dataset1 to output
    resdata = data{1};
    
    % Perform actual arithmetic functions
    switch parameters.operation
        case 'addition'
            resdata.data = data{1}.data + data{2}.data;
            if isfield(data{1},'calculated')
                if isfield(data{2},'calculated')
                    resdata.calculated = ...
                        data{1}.calculated + data{2}.calculated;
                else
                    resdata.calculated = ...
                        data{1}.calculated + data{2}.data;
                end
            end
        case 'subtraction'
            resdata.data = data{1}.data - data{2}.data;
            if isfield(data{1},'calculated')
                if isfield(data{2},'calculated')
                    resdata.calculated = ...
                        data{1}.calculated - data{2}.calculated;
                else
                    resdata.calculated = ...
                        data{1}.calculated - data{2}.data;
                end
            end
        case 'scaling'
            if nargin < 3 && ~isfield(parameters.scalingFactor)
                warnings = 'No scaling factor specified.';
                return;
            elseif ~isfield(parameters.scalingFactor)
                parameters.scalingFactor = varargin{1};
            end
            resdata.data = data{1}.data * parameters.scalingFactor;
            if isfield(data{1},'calculated')
                resdata.calculated = ...
                    data{1}.calculated * parameters.scalingFactor;
            end
        otherwise
            trEPRoptionUnknown(operation,'operation');
            return;
    end
    
    % Write history record
    history = trEPRdataStructure('history');
    history.method = mfilename;
    history.parameters = parameters;
    resdata.history{end+1} = history;

catch exception
    trEPRexceptionHandling(exception);
end

end

