% PAGES List of pages for help window
%
% Format:
%   pageList - cell array (nx3)
%
%   1st column: Description as it should appear in the listbox
%
%   2nd column: filename of the file for the corresponding topic
%               (without extension, "html" is assumed)
%
%   3rd column: Lengthlier description (currently unused, might be empty)
%
% Important notes:
%
%   * The variable needs to be named "pageList".
%
%   * The sequence of the entries (rows) in the pageList cell array
%     determines the sequence of entries in the listbox.

% Copyright (c) 2014, Till Biskup
% 2014-08-10

pageList = {...
    'Datasets','datasets'; ...
    'Accumulate','accumulate'; ...
    'Settings','settings'; ...
    };
