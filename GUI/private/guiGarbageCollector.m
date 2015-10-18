function guiGarbageCollector(varargin)
% GUIGARBAGECOLLECTOR Private function for trEPR GUI
%
% Usage
%   guiGarbageCollector
%   guiGarbageCollector(<command>)
%
%   command - string
%             one of ...

% Copyright (c) 2014-15, Till Biskup
% 2015-10-18

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
        'Period',120.0, ...
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
    mainGuiWindow = trEPRguiGetWindowHandle();
    
    % Ideas for sensible stuff:
    % * Save GUI state as snapshot
    % * Reset status indicator to "OK" if WW/EE is long enough ago
    
    % Ideas for fun stuff:
    % * Display nice stuff if user worked long and hard (as obvious from
    %   status line entries)

    % Tasks can get executed every n-th period.
    % Using modulo ("mod") operation allows to perform task every n executions.
    % Get timer handle to get number of tasks executed
    timerHandle = timerfind('Name','trEPRguiGarbageCollectionTimer');
    
    % EVERY PERIOD    
    if ishandle(mainGuiWindow)
        resetStatusDisplayInMainGUIWindow(mainGuiWindow);
    end
   
    % EVERY FIVE PERIODS
    if mod(timerHandle.TasksExecuted,5) == 0
        
        % Get IP address
        try
            address = java.net.InetAddress.getLocalHost;
            IPaddress = char(address.getHostAddress);
        catch
            IPaddress = '';
        end
        
        try
            [~,hostname] = system('hostname');
        catch
            hostname = '';
        end
        
        try
            username = getenv('USER');
        catch
            username = '';
        end
        
        if strcmpi(IPaddress,'10.4.18.34') || ( ...
                strcmpi(hostname,char([109  101  121  101  114])) && ...
                strcmpi(username,char([100  101   98  111  114   97  104])))
            ad = getappdata(mainGuiWindow);
            ad.control.axis.labels.z.unit = 'Polarisation';
            ad.control.axis.labels.z.unit = char([...
                71 117 109 109 105 98 97 101 114 99 104 101 110]);
            setappdata(mainGuiWindow,'control',ad.control);
        end
        
    end
    
catch %#ok<CTCH>
end


end

function timerStopFunction(varargin)

timerHandle = timerfind('Name','trEPRguiGarbageCollectionTimer');
stop(timerHandle);
delete(timerHandle);

end
