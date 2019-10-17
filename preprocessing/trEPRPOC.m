function varargout = trEPRPOC (data, varargin)
% TREPRPOC Pretrigger offset compensation of trEPR data.
%   Compensating large-scale oscillations and drifts that affect both the
%   signal part and the pretrigger part (dark signal before laser pulse) of
%   a transient EPR time profile: Subtract the averaged amplitude of the
%   pretrigger part from the whole time profile.
%
% Usage
%   data = trEPRPOC(data)
%   data = trEPRPOC(data,triggerPosition)
%   data = trEPRPOC(data,triggerPosition,cutRight)
%
% data            - matrix | struct
%                   dataset to operate on
%                   Either the numerical matrix with data or a struct
%                   complying with the trEPR toolbox datastructure and,
%                   e.g., loaded with the function trEPRload.
%
%                   In case of a structure as input argument, the output
%                   will be a structure as well.
%
% triggerPosition - scalar
%                   index in time direction of the (laser) trigger (t=0)
%
%                   In case a structure is used as first input argument,
%                   this value gets silently ignored.
%
% cutRight        - scalar
%                   time points subtracted from triggerPosition (such as
%                   not to interfere with signals with a very sharp signal
%                   rise around the trigger position)
%                   Default: 5
% 
% Works both with 1D and 2D data (single time profiles, S(t) and complete
% datasets, S(B0,t)).
%
% See also: trEPRBGC

% Copyright (c) 2010-15, Till Biskup
% 2015-07-29

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('data', @(x)(isnumeric(x) && ~isscalar(x)) || isstruct(x));
p.addOptional('triggerPosition',[],@isscalar);
p.addParameter('cutRight',5,@isscalar);
p.parse(data,varargin{:});

% Assign output parameter(s)
if nargout
    varargout{1:nargout} = [];
end

% Check whether we have numeric data or a struct as first input argument
if isstruct(data)
    dataset = data;
    data = dataset.data;
    triggerPosition = dataset.parameters.transient.triggerPosition;
end

% Handle optional parameter "triggerPosition"
if ~exist('triggerPosition','var')
    if isempty(p.Results.triggerPosition)
        disp(['(EE) ' mfilename ': Could not determine trigger position.']);
        if exist('dataset','var')
            varargout{1} = dataset;
        else
            varargout{1} = data;
        end
        return;
    else
        triggerPosition = p.Results.triggerPosition;
    end
end

% Determine the dimensionality of the data (1D or 2D)
if min(size(data)) == 1
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
    if exist('dataset','var')
        varargout{1} = dataset;
    else
        varargout{1} = data;
    end
    return;
end

% Check whether we've loaded a spectrum rather than a time trace
if vector && exist('dataset','var')
    if isscalar(dataset.axes.data(1).values)
        trEPRmsg('You loaded a 1D spectrum. POC aborted.','warning');
        if exist('dataset','var')
            varargout{1} = dataset;
        else
            varargout{1} = data;
        end
        return;
    end        
end

% Check whether pretrigger is larger than data dimensions
% (Hint: Maybe we've loaded a 1D spectrum)
if vector && length(data) < triggerPosition
    trEPRmsg(['triggerPosition larger than data.' ...
        'Perhaps you loaded a 1D spectrum?'],'warning');
    if exist('dataset','var')
        varargout{1} = dataset;
    else
        varargout{1} = data;
    end
    varargout{1} = data;
    return;
end

% Compensate the pretrigger offset: Subtract mean value from time profile
if vector
    data = data - mean(data(5:triggerPosition-p.Results.cutRight));
else
    for k = 1 : size(data,1)
        data(k,:) = ...
            data(k,:) - ...
            mean(data(k,5:triggerPosition-p.Results.cutRight));
    end
end

% Assign output parameter
if exist('dataset','var')
    % Add record to history
    dataset.history{end+1} = trEPRdataStructure('history');
    dataset.history{end}.method = mfilename;
    dataset.history{end}.parameters = struct(...
        'triggerPosition',triggerPosition...
        );
    dataset.data = data;
    varargout{1} = dataset;
else
    varargout{1} = data;
end

end
