function [status,warnings] = trEPRguiCmdParser(cmd,varargin)
% TREPRGUICMDPARSER Helper function parsing commands entered at the command
% line of the trEPR GUI.
%
% Usage:
%   trEPRguiCmdParser(cmd)
%   trEPRguiCmdParser(cmd,opt)
%   [status,warnings] = trEPRguiCmdParser(cmd,opt)
%
%   cmd     - string
%             Command to be executed
%
%   opt     - cell array
%             Options of the command
%
%   status  - scalar
%             Return value for the exit status:
%              0: command successfully performed
%             -1: no trEPRgui window found
%             -2: trEPRgui window appdata don't contain necessary fields
%             -3: some other problems
%
%  warnings - cell array
%             Contains warnings/error messages if any, otherwise empty

% (c) 2013, Till Biskup
% 2013-02-05

status = 0;
warnings = cell(0);

% If called with no input arguments, just display help and exit
if (nargin==0)
    help trEPRguiCmdParser;
    return;
end

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('cmd', @(x)ischar(x));
p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(cmd,varargin{:});
opt = p.Results.opt;

% % For the time being, print apologies to the Matlab console
% fprintf('%s%s\n%s\n','Sorry, this function doesn''t work yet. ',...
%     'Please, come back later.',...
%     'We apologise for any inconvenience this may cause.');
% return;

% Is there currently a trEPRgui object?
mainWindow = trEPRguiGetWindowHandle();
if (isempty(mainWindow))
    warnings{end+1} = 'No trEPRgui window could be found.';
    status = -1;
    return;
end

% Get appdata from mainwindow
ad = getappdata(mainWindow);
% Get handles from main GUI
% gh = guidata(mainWindow);

% For convenience and shorter lines
active = ad.control.spectra.active;

switch lower(cmd)
    case 'pick'
        if isempty(opt)
            trEPRmsg(['Command "' lower(cmd) '" needs options.'],'warning');
            return;
        end
        if ~active
            trEPRmsg(['Command "' lower(cmd) '" needs an active dataset.'],'warning');
            return;
        end
        switch lower(opt{1}(1:3))
            case 'min'
                [~,ximin] = min(min(ad.data{active}.data));
                [~,yimin] = min(ad.data{active}.data(:,ximin));
                ad.data{active}.display.position.x = ximin;
                ad.data{active}.display.position.y = yimin;
                
                % Set appdata from main GUI
                setappdata(mainWindow,'data',ad.data);
        
                % Update slider panel
                update_sliderPanel();
                
                %Update main axis
                update_mainAxis();
                return;
            case 'max'
                [~,ximax] = max(max(ad.data{active}.data));
                [~,yimax] = max(ad.data{active}.data(:,ximax));
                ad.data{active}.display.position.x = ximax;
                ad.data{active}.display.position.y = yimax;
                
                % Set appdata from main GUI
                setappdata(mainWindow,'data',ad.data);
                
                % Update slider panel
                update_sliderPanel();
                
                %Update main axis
                update_mainAxis();
                return;
        end
    otherwise
        % For debug purposes.
        disp(cmd);
        if ~isempty(opt)
            celldisp(opt);
        end
end

end