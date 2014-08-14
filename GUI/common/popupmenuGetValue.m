function value = popupmenuGetValue(handle)
% POPUPMENUGETVALUE Get value of popup menu.
%
% Usage:
%   popupmenuGetValue(handle,value)
%
%   handle - handle
%            Handle of the popup menu to get the value from
%
%   value  - string
%            Current (selected) value of the popup menu
%
% See also: uicontrol, popupmenuSetValue

% Copyright (c) 2014, Till Biskup
% 2014-08-07

value = '';

% If called without parameter, display help
if ~nargin && ~nargout
    help popupmenuSetValue
    return;
end

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addRequired('handle',@(x)ishandle(x));
    p.parse(handle);
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Check whether handle is from a popup menu
if ~strcmpi(get(handle,'Style'),'popupmenu')
    trEPRmsg('Handle not that of a popup menu','warning');
    return;
end

values = cellstr(get(handle,'String'));
value = values{get(handle,'Value')};

end
