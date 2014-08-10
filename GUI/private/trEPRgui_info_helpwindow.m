function varargout = trEPRgui_info_helpwindow(varargin)
% TREPRGUI_INFO_HELPWINDOW Display help window for trEPR toolbox info
% window.
% Cannot be called externally.
%
% See also: helpWindow

% Copyright (c) 2011-14, Till Biskup
% 2014-08-10

% Get basedir
[basedir,~,~] = fileparts(mfilename('fullpath'));

helpWindow(...
    'tag',mfilename,...
    'title','Test',...
    'basedir',fullfile(basedir,'helptexts','info') ...
    );

end
