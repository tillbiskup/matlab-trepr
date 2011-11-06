% TREPRTOOLBOXREVISION Return trEPR toolbox revision number and date
%
% Usage
%   trEPRtoolboxRevision
%   version = trEPRtoolboxRevision;
%
%   version - struct
%             Fields: Name, Version, Release, Date
%             The structure of this struct is identical to that of the
%             Matlab(r) "ver" command.
%
% See also TREPRINFO.

% (c) 2007-11, Till Biskup
% 2011-11-06

function [ varargout ] = trEPRtoolboxRevision
% The place to centrally manage the revision number and date is the file
% "Contents.m" in the root directory of the trEPR toolbox.
%
% THE VALUES IN THAT FILE SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER
% OF THE TOOLBOX!
%
% As the "ver" command works not reliably, as it works only in case the
% toolbox is on the Matlab(r) search path, we parse this file here
% manually.
%
% If you have questions, call the trEPRinfo routine at the command prompt
% and contact the maintainer via the email address given there.

% Get path to file "Contents.m"
[path,~,~] = fileparts(mfilename('fullpath'));
contentsFile = [ path(1:end-8) 'Contents.m' ];
% Read first two lines of "Contents.m"
contentsFileHeader = cell(2,1);
fid = fopen(contentsFile);
k=1;
for k=1:2
    contentsFileHeader{k} = fgetl(fid);
end
fclose(fid);

C = textscan(contentsFileHeader{2}(3:end),'%s %s %s %s');

versionInfo = struct();
versionInfo.Name = contentsFileHeader{1}(3:end);
versionInfo.Version = C{2}{1};
if isempty(C{4})
    versionInfo.Release = '';
    versionInfo.Date = ...
        datestr(datenum(char(C{3}{1}), 'dd-mmm-yyyy'), 'yyyy-mm-dd');
else
    versionInfo.Release = C{3}{1};
    versionInfo.Date = ...
        datestr(datenum(char(C{4}{1}), 'dd-mmm-yyyy'), 'yyyy-mm-dd');
end

if nargout
    varargout{1} = versionInfo;
else
    % in case the function is called without output parameters
    fprintf('%s %s\n',versionInfo.Version,versionInfo.Date)
end

end