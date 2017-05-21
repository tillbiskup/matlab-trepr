function hg2 = commonIsHG2(fig)
% COMMONISHG2 Check whether figure object is a HG2 object.
%
% Usage:
%   tf = commonIsHG2(figureHandle)
%
% Matlab changed its graphics stack entirely with version 8.4 (R2014b),
% rendering many things incompatible to eariler behaviour, thus breaking
% lots of code, partly in very subtle ways.
%
% SEE ALSO: commonHG2Support

% Copyright (c) 2017, Till Biskup
% 2017-05-21

% This code is based on ideas discussed in the Matlab forum:
% https://de.mathworks.com/matlabcentral/answers/136834-determine-if-using-hg2

if verLessThan('matlab','8.4.0')
    hg2 = false;
else
    try
        hg2 = strcmp(get(fig,'GraphicsSmoothing'),'on'); 
    catch
        hg2 = false; 
    end
end

end