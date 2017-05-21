function hg2 = commonHG2Support()
% COMMONHG2SUPPORT Check whether Matlab version currently used supports the
% HG2 graphics system introduced with Matlab 2014b (8.4). 
%
% Usage:
%   tf = commonHG2Support()
%
% Matlab changed its graphics stack entirely with version 8.4 (R2014b),
% rendering many things incompatible to eariler behaviour, thus breaking
% lots of code, partly in very subtle ways.
%
% SEE ALSO: commonIsHG2

% Copyright (c) 2017, Till Biskup
% 2017-05-21

% This code is based on ideas discussed in the Matlab forum:
% https://de.mathworks.com/matlabcentral/answers/136834-determine-if-using-hg2

if verLessThan('matlab','8.4.0')
    hg2 = false;
else
    hg2 = true;
end

end