function data = getData(dataset)
% GETDATA Get the data of current dataset.
%
% Necessary in case that a dataset has no experimental data, but only
% calculated data.
%
% Usage:
%   data = getData(dataset)
%
% dataset - struct
%           Dataset conforming to trEPR toolbox datastructure
%
% data    - matrix
%           Data of current dataset.
%           Experimental data, if available, otherwise calculated data.
%           Empty if none exists.

% (c) 2013, Till Biskup
% 2013-08-24

if ~isempty(dataset.data)
    data = dataset.data;
elseif ~isempty(dataset.calculated)
    data = dataset.calculated;
else
    trEPRmsg('Serious problem: No data found','error');
    data = [];
    return;
end

end