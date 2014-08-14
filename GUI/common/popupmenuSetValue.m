function popupmenuSetValue(handle,value)
% POPUPMENUSETVALUE Set value for popup menu.
%
% Usage:
%   popupmenuSetValue(handle,value)
%
%   handle - handle
%            Handle of the popup menu to set the value for
%
%   value  - string
%            Valid value for the popup menu (one of the strings contained
%            in the popup menu's "String" property)
%
% See also: uicontrol, popupmenuGetValue

% Copyright (c) 2014, Till Biskup
% 2014-08-07

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
    p.addRequired('value',@(x)ischar(x));
    p.parse(handle,value);
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
value = find(strcmpi(value,values));

if isempty(value)
    trEPRmsg(['"' value '" not a valid value'],'warning');
    return;
end

set(handle,'Value',value);

end
