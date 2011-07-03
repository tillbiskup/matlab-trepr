function trEPRinfo
%TREPRINFO Display basic information about the trEPR toolbox

%   Copyright 2007,2011 Till Biskup
%   $Revision: 1307 $  $Date: 2011-06-22 06:48:31 +0100 (Mi, 22 Jun 2011) $

% 	fprintf('\nFUNCTION CALL: $Id: trEPRinfo.m 1307 2011-06-22 05:48:31Z till $\n\n');

try
    [ tbRevNo, tbRevDate ] = trEPRtoolboxRevision;
    DisplayPlatform = platform;
    
    fprintf('=================================================================\n\n');
    fprintf(' trEPR toolbox\n');
    fprintf(' a Matlab toolbox for transient Electron Paramagnetic Resonance  \n\n');
    fprintf('   Release:          %s (%s) \n', tbRevNo, tbRevDate);
    fprintf('   Directory:        %s \n',trEPRtoolboxdir);
    fprintf('   Matlab version:   %s \n',version);
    fprintf('   Platform:         %s \n\n',DisplayPlatform);
    fprintf('=================================================================\n\n');
    fprintf(' For latest information, please visit:\n\n');
    fprintf('   http://till-biskup.de/de/software/matlab/trepr/\n\n');
    fprintf(' or write an email to <till@till-biskup.de>\n\n');
    fprintf('=================================================================\n\n');
catch exception
    disp('There seems to be a problem with displaying the info...');
    throw(exception);
end
end