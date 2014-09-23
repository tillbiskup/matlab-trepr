function [status,warnings] = cmdFilter(handle,opt,varargin)
% CMDFILTER Command line command of the trEPR GUI.
%
% Usage:
%   cmdFilter(handle,opt)
%   [status,warnings] = cmdFilter(handle,opt)
%
%   handle  - handle
%             Handle of the window the command should be performed for
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: GUI window found
%             -2: missing options
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% Copyright (c) 2014, Till Biskup
% 2014-09-23

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Include function name in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = lower(cmd(4:end));

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

% For convenience and shorter lines
active = ad.control.data.active;

if isempty(opt)
    return;
end
    
% Check for minumum number of options
if length(opt) < 2
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Create empty structure for filter parameters
filter = struct(...
    'filterfun','',...
    'parameters',struct(...
        'width',0,...
        'order',2,...
        'deriv',0 ...
        )...
    );

% Check whether first option is numeric (-> dataset no) or char (dim)
if ~isnan(str2double(opt{1}))
    dataset = str2double(opt{1});
    % Remove first option
    opt(1) = [];
else
    dataset = active;
    % If there is no active dataset, return
    if ~active
        warnings{end+1} = sprintf('Command "%s": No active dataset.',cmd);
        status = -3;
        return;
    end
end
% Check for dimension
if any(strcmpi(opt{1},{'x','y'}))
    dimension = lower(opt{1});
else
    warnings{end+1} = sprintf(...
        'Command "%s": Wrong dimension "%s".',cmd,lower(opt{1}));
    status = -3;
    return;
end
% Check for type
switch lower(opt{2})
    case 'boxcar'
        filter.filterfun = 'trEPRfilter_boxcar';
    case {'binom','binomial'}
        filter.filterfun = 'trEPRfilter_binomial';
    case {'savgol','savitzky-golay'}
        filter.filterfun = 'trEPRfilter_SavitzkyGolay';
    case {'none'}
        filter.filterfun = '';
        % Set filter options in dataset
        ad.data{dataset}.display.smoothing.data.(dimension) = filter;
        setappdata(handle,'data',ad.data);
        trEPRguiUpdate;
        return;
    otherwise
        warnings{end+1} = sprintf(...
            'Command "%s": Wrong filter type "%s".',cmd,lower(opt{2}));
        status = -3;
        return;
end
% Check for minumum number of options
% If we are here, there has to be at least three options
if length(opt) < 3
    warnings{end+1} = sprintf(...
        'Command "%s": Not enough options. Use "help %s" to get some help.',cmd,cmd);
    status = -2;
    return;
end

% Check for width
if length(opt{3})>5 && strncmpi('width=',opt{3},6) ...
        && ~isnan(str2double(opt{3}(7:end)))
    filter.parameters.width = str2double(opt{3}(7:end));
elseif ~isnan(str2double(opt{3}))
    filter.parameters.width = str2double(opt{3});
else
    warnings{end+1} = sprintf(...
        'Command "%s": Wrong width "%s".',cmd,lower(opt{3}));
    status = -3;
    return;
end
% Check for order and deriv
if length(opt)>3
    for optIdx = 4:length(opt)
        if strncmpi('order=',opt{optIdx},6) ...
                && ~isnan(str2double(opt{optIdx}(7:end)))
            filter.parameters.order = str2double(opt{optIdx}(7:end));
        end
        if strncmpi('deriv=',opt{optIdx},6)...
                && ~isnan(str2double(opt{optIdx}(7:end)))
            filter.parameters.deriv = str2double(opt{optIdx}(7:end));
        end
    end
end
% Set filter options in dataset
ad.data{dataset}.display.smoothing.data.(dimension) = filter;
setappdata(handle,'data',ad.data);
trEPRguiUpdate;
end

