function trEPRguiUpdateCheck
% TREPRGUIUPDATECHECK Function starting a timer to check for toolbox
% updates and displaying a dialogue box if there are some updates.
%
% Used to prevent, e.g., the GUI from starting in time due to timeout
% problems of the network.
%
% Usage:
%   trEPRguiUpdateCheck
%
% See also: trEPRupdateCheck

% Copyright (c) 2014, Till Biskup
% 2014-08-14

% Ensure there is only one timer for checking for updates
timerHandle = timerfind('Name','trEPRupdateCheckTimer');

if isempty(timerHandle)
    timerHandle = timer(...
        'Name','trEPRupdateCheckTimer', ...
        'TimerFcn',@timerExecuteFunction,...
        'StopFcn',@timerStopFunction,...
        'StartDelay',5, ...
        'ExecutionMode','singleShot' ...
        );
end

if isvalid(timerHandle)
    start(timerHandle);
end

end


function timerExecuteFunction(varargin)

try
    if trEPRupdateCheck
        msgWindow('A new version of the toolbox is available online.',...
            'title','Update availabe','icon','info');
    end
catch %#ok<CTCH>
end

end

function timerStopFunction(varargin)

timerHandle = timerfind('Name','trEPRupdateCheckTimer');
stop(timerHandle);
delete(timerHandle);

end
