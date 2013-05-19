function [status,warnings] = cmdTips(handle,opt,varargin)
% CMDTIPS Command line command of the trEPR GUI.
%
% Usage:
%   cmdTips(handle,opt)
%   [status,warnings] = cmdTips(handle,opt)
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

% (c) 2013, Till Biskup
% 2013-05-19

status = 0;
warnings = cell(0);

% Parse input arguments using the inputParser functionality
p = inputParser;   % Create an instance of the inputParser class.
p.FunctionName = mfilename; % Function name to be included in error messages
p.KeepUnmatched = true; % Enable errors on unmatched arguments
p.StructExpand = true; % Enable passing arguments in a structure

p.addRequired('handle', @(x)ishandle(x));
p.addRequired('opt', @(x)iscell(x));
%p.addOptional('opt',cell(0),@(x)iscell(x));
p.parse(handle,opt,varargin{:});
handle = p.Results.handle;
opt = p.Results.opt;

% Get command name from mfilename
cmd = mfilename;
cmd = cmd(4:end);

% Is there the GUI requested?
if (isempty(handle))
    warnings{end+1} = 'No GUI window could be found.';
    status = -1;
    return;
end

% Get appdata from handle
ad = getappdata(handle);

if isempty(opt)
    showTips = showTip('File',fullfile(...
        trEPRinfo('dir'),'GUI','private','helptexts','tips.txt'));
    if isfield(ad.configuration,'start') ...
            && isfield(ad.configuration.start,'tip')
        conf = trEPRguiConfigLoad('trEPRgui');
        conf.start.tip = showTips;
        warnings = guiConfigWrite('trEPRgui',conf);
        if warnings
            trEPRmsg(warnings,'warning');
        end
    end
    return;
end

switch lower(opt{1})
    case {'show','on','1','true'}
        if isfield(ad.configuration,'start') ...
                && isfield(ad.configuration.start,'tip')
            conf = trEPRguiConfigLoad('trEPRgui');
            conf.start.tip = 1;
            warnings = guiConfigWrite('trEPRgui',conf);
            if warnings
                trEPRmsg(warnings,'warning');
            end
        end
    case {'hide','off','0','false'}
        if isfield(ad.configuration,'start') ...
                && isfield(ad.configuration.start,'tip')
            conf = trEPRguiConfigLoad('trEPRgui');
            conf.start.tip = 0;
            warnings = guiConfigWrite('trEPRgui',conf);
            if warnings
                trEPRmsg(warnings,'warning');
            end
        end
    otherwise
        trEPRmsg(['Command ' lower(cmd) ': option ' lower(opt{1}) ...
            ' not understood'],'warning');
        return;
end

end

