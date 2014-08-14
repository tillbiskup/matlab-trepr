function update = trEPRupdateCheck
% TREPRUPDATECHECK Check for update of toolbox on toolbox homepage.
% Therefore, it requires an existing internet connection
%
% Usage:
%   update = trEPRupdateCheck
%
%   update - boolean
%            true if an update is available
%
% NOTE: This function makes use of knowledge of the contents of the
%       toolbox homepage that it parses to get the relevant information.
%       Therefore, it is likely to break if the toolbox homepage changes
%       and the toolbox author forgets to keep track of this...
%
% A note on privacy: Although it might be in principle possible to track
% which IP accessed when the webpage, and therefore to get sort of a "user
% statistics" for the toolbox, this is not at all intended by the toolbox
% author. If you don't like to access the toolbox webpage in this way, just
% don't use this function.

% Copyright (c) 2014, Till Biskup
% 2014-08-06

update = false;

% Matching pattern
% NOTE: This relies on knowledge of the contents of the toolbox homepage
%       and is likely to break once this homepage gets restructured.
matchingPattern = 'development release</a>: v.';

% Get webpage
[webpage,status] = urlread(trEPRinfo('url'));

if ~status
    trEPRmsg('Problem accessing toolbox homepage','warning');
    return;
end

% Find match
matchingPosition = strfind(webpage,matchingPattern);
webVersionString = webpage(matchingPosition+length(matchingPattern):...
    matchingPosition+length(matchingPattern)+19);

% Parse match
% 1st - separate version and date
tmp = regexp(webVersionString,' ','split');
webVersion = tmp{1};
tmp2 = regexp(tmp{2},'\((.*)\)','tokens');
webDate = tmp2{1}{1};
clear tmp tmp2

% Parse toolbox version string from trEPRinfo
toolboxVersionString = trEPRinfo('version');
tmp = regexp(toolboxVersionString,' ','split');
toolboxVersion = tmp{1};
toolboxDate = tmp{2};

% First easy check: date comparison
% If webDate is more recent, there should be an update available...
if datenum(toolboxDate,'yyyy-mm-dd') < datenum(webDate,'yyyy-mm-dd')
    update = true;
    return
end

% Second check: compare versions
if any(str2double(regexp(toolboxVersion,'\.','split')) < ...
        str2double(regexp(webVersion,'\.','split')))
    update = true;
    return;
end

end
