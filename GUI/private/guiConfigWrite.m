function status = guiConfigWrite(guiname,conf)
% GUICONFIGLOAD Save configuration parameters for a given GUI window back
% to its configuration file
%
% The idea is to minimise the files that contain the actual path to the
% config files, such as to make life easier if this changes.
%
% Usage
%   status = guiConfigLoad(guiname,conf)
%
%   guiname - string
%             Valid mfilename of a GUI
%
%   conf    - struct
%             Contains all configuration parameters of the given GUI
%             Empty if no configuration could be read.
%
%   status  - string
%             Empty if everything went well. Otherwise error message.
%
% See also GUICONFIGREAD, GUICONFIGAPPLY, TREPRINIFILEREAD,
% TREPRINIFILEWRITE 

% Copyright (c) 2012, Till Biskup
% 2012-04-21

try

    % Define config file
    confFile = fullfile(...
        trEPRinfo('dir'),'GUI','private','conf',[guiname '.ini']);
    header = 'Configuration file for trEPR toolbox';
    status = trEPRiniFileWrite(confFile,conf,'header',header,'overwrite',true);
catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
