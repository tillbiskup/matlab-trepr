function styles = lineStyles
% LINESTYLES Return cell array of line styles in both descriptive manner
% and as symbols
%
% Usage:
%   styles = lineStyles
%
%   styles - cell array
%            1st column: description of line styles
%            2nd column: symbols understood by Matlab(r) for line styles

% Copyright (c) 2014, Till Biskup
% 2014-08-07

styles = {...
    'solid','-'; ...
    'dashed','--'; ...
    'dotted',':'; ...
    'dash-dotted','-.'; ...
    'none','none' ...
    };

end
