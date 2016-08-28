function posixTime = datevec2posixtime(dateVector)
% DATEVEC2POSIXTIME Convert Matlab(r) date vector to POSIX time, aka
% seconds since 1970-01-01.
%
% Usage:
%   posixTime = datevec2posixtime(dateVector)
%
%   dateVector - Matlab(r) date vector
%                vector with six elements: yyyy, mm, dd, HH, MM, SS
%                see help for "datevec"
%
%   posixTime  - scalar
%                Seconds since 1970-01-01
%
% Note that this routine doesn't care about leap seconds, and by using
% Matlab(r)'s "datenum" to conpute the days, possibly not about leap years
% as well.

% Copyright (c) 2016, Till Biskup
% 2016-08-28

% POSIX time starts with January 1st, 1970
% "floor" is used to get only the day from "datenum", no fractionals
% "datenum" is supposed to return the days since January 1st, 0000
% No clue whether it accounts for leap years and such things...
posixZeroTime = floor(datenum('1970-01-01'));
daysSincePosixZeroTime = floor(datenum(dateVector)) - posixZeroTime;

HOURSPERDAY = 24;
MINUTESPERHOUR = 60;
SECONDSPERMINUTE = 60;

% Matlab(r) datevec contains six values: yyyy, mm, dd, HH, MM, SS
posixTime = ...
    SECONDSPERMINUTE*MINUTESPERHOUR*HOURSPERDAY*daysSincePosixZeroTime ...
    + dateVector(4)*SECONDSPERMINUTE*MINUTESPERHOUR ...
    + dateVector(5)*SECONDSPERMINUTE + dateVector(6);

end