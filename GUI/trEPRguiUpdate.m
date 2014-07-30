function trEPRguiUpdate(varargin)
% TREPRGUIUPDATE Update GUI display to resemble change in underlying
% appdata stucture.
%
% Usage:
%   trEPRguiUpdate
%
% See also: update_*

% Copyright (c) 2014, Till Biskup
% 2014-07-30

% Needs to be way more intelligent. For now, just call all the update
% functions

% Get update functions
[path,~,~] = fileparts(mfilename('fullpath'));
updateFuns = dir(fullfile(path,'private','update_*.m'));

for updateFun = 1:length(updateFuns)
    fun = str2func(updateFuns(updateFun).name(1:end-2));
    fun();
end

end