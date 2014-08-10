function varargout = trEPRgui_MWfrequencyDrift_helpwindow(varargin)
% TREPRGUI_MWFREQUENCYDRIFT_HELPWINDOW Help window for the MW Frequency
% Drift GUI.
%
% Normally, this window is called from within the trEPRgui window. 
%
% Usage:
%   trEPRgui_cmd_helpwindow
%   handle = trEPRgui_cmd_helpwindow
%   trEPRgui_cmd_helpwindow(<parameter>,<value>)
%
% Optional parameters that can be set:
%
%   page      - string
%               Page that should be displayed in the help window.
%               To discern pages with identical name in different
%               subdirectories, a slash ("/") can be used to separate
%               directory and file.
%
%               If the respective page cannot be found, a default page is
%               displayed.
%
% See also: helpWindow

% Copyright (c) 2012-14, Till Biskup
% 2014-08-10

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParamValue('page','',@(x)ischar(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get basedir
[basedir,~,~] = fileparts(mfilename('fullpath'));

hMainFigure = helpWindow(...
    'tag',mfilename,...
    'title','trEPR GUI MW Frequency Drift Analysis',...
    'basedir',fullfile(basedir,'helptexts','MWfrequencyDrift'),...
    'page',p.Results.page ...
    );

end
