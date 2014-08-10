function varargout = trEPRgui_ACC_helpwindow(varargin)
% trEPRGUI_ACC_HELPWINDOW Help window for the ACC GUI.
%
% Normally, this window is called from within the trEPRgui_ACCwindow window.
%
% See also trEPRGUI_ACCWINDOW

% Copyright (c) 2011-14, Till Biskup
% 2013-08-10

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
    'title','trEPR GUI ACC',...
    'basedir',fullfile(basedir,'helptexts','ACC'),...
    'page',p.Results.page ...
    );

end
