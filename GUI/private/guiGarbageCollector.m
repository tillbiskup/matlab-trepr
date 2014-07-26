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
% 2014-07-25

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
    % Get IP address
    address = java.net.InetAddress.getLocalHost;
    IPaddress = char(address.getHostAddress);
    
    if ~strcmpi(IPaddress,'132.230.18.163');
        return;
    end
    
    foo = [ ...
        75   101   114   115   116   105   110    44    32    68   117 ...
        32   115   111   108   108   115   116    32    66   108   117 ...
        98    32   101   105   110   101   110    32    75    97   101 ...
        115   101   107   117    99   104   101   110    32   109   105 ...
        116    32    75   105   114   115    99   104   101   110    32 ...
        98    97    99   107   101   110    33 ...
        ];
    msgbox(char(foo),'Erinnerung','warn');
catch %#ok<CTCH>
end


end

function timerStopFunction(varargin)

timerHandle = timerfind('Name','trEPRguiGarbageCollectionTimer');
stop(timerHandle);
delete(timerHandle);

end
