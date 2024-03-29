function varargout = trEPRgui_AVG_helpwindow(varargin)
% TREPRGUI_AVG_HELPWINDOW Brief description of GUI.
%          Comments displayed at the command line in response 
%          to the help command. 

% Copyright (c) 2011-14, Till Biskup
% 2014-08-10

% Parse input arguments using the inputParser functionality
try
    p = inputParser;            % Create inputParser instance.
    p.FunctionName = mfilename; % include function name in error messages
    p.KeepUnmatched = true;     % Enable errors on unmatched arguments
    p.StructExpand = true;      % Enable passing arguments in a structure
    p.addParameter('page','',@(x)ischar(x));
    p.parse(varargin{:});
catch exception
    disp(['(EE) ' exception.message]);
    return;
end

% Get basedir
[basedir,~,~] = fileparts(mfilename('fullpath'));

hMainFigure = helpWindow(...
    'tag',mfilename,...
    'title','trEPR GUI AVG',...
    'basedir',fullfile(basedir,'helptexts','AVG'),...
    'page',p.Results.page ...
    );

end
