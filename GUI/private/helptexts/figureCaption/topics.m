% TOPICS List of topics for help window
%
% Format:
%   topicList - cell array (nx3)
%
%   1st column: Description as it should appear in the listbox
%
%   2nd column: name of the directory the corresponding help files are
%               located
%
%   3rd column: Lengthlier description (currently unused, might be empty)
%
% Important notes:
%
%   * The variable needs to be named "topicList".
%
%   * The sequence of the entries (rows) in the topicList cell array
%     determines the sequence of entries in the listbox.

% Copyright (c) 2014, Till Biskup
% 2014-08-10

topicList = { ...
    'General topics','general',''; ...
    'Controls description','controls',''; ...
    };
