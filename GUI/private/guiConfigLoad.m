function conf = guiConfigLoad(guiname)
% GUICONFIGLOAD Read configuration parameters for a given GUI window.
%
% The idea is to minimise the files that contain the actual path to the
% config files, such as to make life easier if this changes.
%
% Usage
%   conf = guiConfigLoad(guiname)
%
%   guiname - string
%             Valid mfilename of a GUI
%
%   conf    - struct
%             Contains all configuration parameters of the given GUI
%             Empty if no configuration could be read.
%
% See also GUICONFIGWRITE, GUICONFIGAPPLY, trEPRINIFILEREAD, trEPRINIFILEWRITE

% (c) 2011-12, Till Biskup
% 2012-04-21

try

    % Define config file
    confFile = fullfile(...
        trEPRinfo('dir'),'GUI','private','conf',[guiname '.ini']);
    % If that file does not exist, try to create it from the
    % distributed config file sample
    if ~exist(confFile,'file')
        fprintf('Config file\n  %s\nseems not to exist. %s\n',...
            confFile,'Trying to create it from distributed file.');
        trEPRconf('create','overwrite',true,'file',confFile);
    end
    
    % Try to load and append configuration
    conf = trEPRiniFileRead(confFile,'typeConversion',true);
    if isempty(conf)
        return;
    end

catch exception
    % If this happens, something probably more serious went wrong...
    throw(exception);
end

end
