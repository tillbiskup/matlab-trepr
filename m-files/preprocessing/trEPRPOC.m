function varargout = trEPRPOC (data, triggerPosition, varargin)
% Compensates for large-scale oscillations and drifts that affect both the
% signal part and the pretrigger part (dark signal before laser pulse) of
% a transient EPR time profile: Subtracts the averaged amplitude of the
% pretrigger part from the whole time profile.
% 
% Works both with 1D and 2D data (single time profiles and complete
% datasets).

    % Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

    p.addRequired('data', @(x)isnumeric(x) && ~isscalar(x));
    p.addRequired('triggerPosition', @isscalar);
    p.addOptional('parameters','',@isstruct);
    p.addParamValue('cutRight',5,@isscalar);
    p.parse(data,triggerPosition,varargin{:});

    % Determine the dimensionality of the data (1D or 2D)
    [rows, cols] = size(data);
    if min([rows, cols]) == 1
        vector = logical(true);
    else
        vector = logical(false);
    end

    % Check for appropriate length of pretrigger part of the time profile
    if triggerPosition < 5 || triggerPosition <= (p.Results.cutRight)
        warning(...
            'trEPRPOC:pretriggerShortage',...
            'The pretrigger part of the signal is too short. Aborted.'...
            );
        return;
    end

    % Compensate the pretrigger offset: Subtract mean value from time
    % profile
    if vector
        data = data - mean(data(1:triggerPosition-p.Results.cutRight));
    else
        for k = 1 : rows
            data(k,:) = ...
                data(k,:) - ...
                mean(data(k,1:triggerPosition-p.Results.cutRight));
        end
    end
    
    % Assign output parameter
    varargout{1} = data;
    