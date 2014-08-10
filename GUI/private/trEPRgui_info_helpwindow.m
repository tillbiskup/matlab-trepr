function handle = trEPRgui_info_helpwindow(varargin)
% TREPRGUI_INFO_HELPWINDOW Help window for trEPR toolbox info GUI. 
% Cannot be called externally.
%
% See also: helpWindow

% Copyright (c) 2011-14, Till Biskup
% 2014-08-10

% Get basedir
[basedir,~,~] = fileparts(mfilename('fullpath'));

handle = helpWindow(...
    'tag',mfilename,...
    'title','trEPR Info GUI',...
    'basedir',fullfile(basedir,'helptexts','info') ...
    );

end
