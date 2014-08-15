function guiGarbageCollector(varargin)
% GUIGARBAGECOLLECTOR Private function for trEPR GUI
%
% Usage
%   guiGarbageCollector
%   guiGarbageCollector(<command>)
%
%   command - string
%             one of ...

% Copyright (c) 2014, Till Biskup
% 2014-08-14

% Parse input arguments using the inputParser functionality
p = inputParser;            % Create instance of the inputParser class
p.FunctionName = mfilename; % Function name included in error messages
p.KeepUnmatched = true;     % Enable errors on unmatched arguments
p.StructExpand = true;      % Enable passing arguments in a structure
p.addOptional('command','',@(x)ischar(x));
p.parse(varargin{:});

timerHandle = timerfind('Name','trEPRguiGarbageCollectionTimer');

if isempty(timerHandle)
    timerHandle = timer(...
        'Name','trEPRguiGarbageCollectionTimer', ...
        'TimerFcn',@timerExecuteFunction,...
        'StopFcn',@timerStopFunction,...
        'Period',600.0, ...
        'StartDelay',120, ...
        'ExecutionMode','fixedDelay' ...
        );
end

if nargin && isfield(p.Results,'command')
    switch lower(p.Results.command)
        case 'start'
            if isvalid(timerHandle)
                start(timerHandle);
            end
        case 'stop'
            if isvalid(timerHandle)
                stop(timerHandle);
                delete(timerHandle);
            end
    end
end

end

function timerExecuteFunction(varargin)

try
    % Ideas for sensible stuff:
    % * Save GUI state as snapshot
    % * Reset status indicator to "OK" if WW/EE is long enough ago
    
    % Ideas for fun stuff:
    % * Display nice stuff if user worked long and hard (as obvious from
    %   status line entries)
    
    % Get IP address
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    
    if strcmpi(IPaddress,'132.230.18.138')
        hMainFigure = trEPRguiGetWindowHandle();
        ad = getappdata(hMainFigure);
        ad.control.axis.labels.z.unit = 'Polarisation';
        ad.control.axis.labels.z.unit = char([...
            71 117 109 109 105 98 97 101 114 99 104 101 110]);
        setappdata(hMainFigure,'control',ad.control);
    end
catch %#ok<CTCH>
end


end

function timerStopFunction(varargin)

timerHandle = timerfind('Name','trEPRguiGarbageCollectionTimer');
stop(timerHandle);
delete(timerHandle);

end
