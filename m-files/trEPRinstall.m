function trEPRinstall
% TRPERINSTALL  Install the trEPR toolbox (set Matlab path)

% Copyright (C) 2007,2011 Till Biskup, <till@till-biskup.de>
% This file ist free software.
% $Revision$  $Date$

% Do the real stuff
	
% First of all, define some important variables, as the revision number
% and the directories for the toolbox
	
trEPRtoolboxRevisionNumber = trEPRtoolboxRevision;
	
trEPRtoolboxBaseDir = sprintf('trEPR-%s',trEPRtoolboxRevisionNumber);
trEPRtoolboxProgDir = sprintf('%s/trEPR',trEPRtoolboxBaseDir);
trEPRtoolboxDocDir = sprintf('%s/documentation',trEPRtoolboxBaseDir);
trEPRtoolboxExampleDir = sprintf('%s/examples',trEPRtoolboxBaseDir);

% Print out some greeting message

greetingMessage = {...
    ' '...
    '================================================================='...
    ' '...
    ' Welcome to the INSTALLATION PROCEDURE of'...
    ' '...
    '       tt                EEEEEEEEEE  PPPPPPPP    RRRRRRRR        '...
    '       tt                EEEEEEEEEE  PPPPPPPPP   RRRRRRRRR       '...
    '       tt                EE          PP      PP  RR      RR      '...
    '       tt                EE          PP      PP  RR      RR      '...
    '   tttttttttt  rr  rrrr  EEEEEEEEEE  PPPPPPPPP   RRRRRRRRR       '...
    '   tttttttttt  rrrr  rr  EEEEEEEEEE  PPPPPPPP    RRRRRRRR        '...
    '       tt      rrr       EE          PP          RR     RR       '...
    '       tt      rr        EE          PP          RR     RR       '...
    '       tt      rr        EE          PP          RR      RR      '...
    '       tt      rr        EEEEEEEEEE  PP          RR      RR      '...
    '        ttt    rr        EEEEEEEEEE  PP          RR      RR      '...
    ' '...
    ' '...
    ' a Matlab toolbox for transient Electron Paramagnetic Resonance'...
    sprintf(' Revision %s',trEPRtoolboxRevisionNumber)...
    ' '...
    '================================================================='...
    ' '...
    };

for k=1:length(greetingMessage)
    fprintf('%s\n',greetingMessage{k});
end

% First of all, check whether there is a version of the trEPR toolbox installed
% and if so, print out a short message and abort further processing
	
if ( strfind(path,'trEPR'))

	fprintf('PLEASE NOTE:\n\n');
    fprintf('It seems as if you have already installed the trEPR toolbox.\n');
	fprintf('Type "trEPRinfo" to receive information about the\n');
    fprintf('currently installed version.\n\n')
	return;
    
    % TODO: Remove path to installed toolbox, install new path

end

% In case there is no version of the trEPR toolbox currently installed,
% (or, more precise, the program "trEPRinfo" is not in the MATLAB search path)
% proceed with the installation
	
% Add the current directory and the other directories of the toolbox
% to the MATLAB(TM) search path.
%
% Therefore, make sure we are called from the path we are installed to.
% Otherwise, print out a short message and abort further processing.

if ( strfind(pwd,trEPRtoolboxProgDir) ~= 0 ) 
	
    fprintf('Adding the trEPR toolbox directories to the MATLAB(TM) search path...\n')
	
	trEPRtoolboxRootDir = strrep(pwd,trEPRtoolboxProgDir,'');
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxBaseDir));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxProgDir));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxProgDir,'/GUI'));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxProgDir,'/IO'));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxProgDir,'/preprocessing'));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxProgDir,'/common'));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxDocDir));
	addpath(fullfile(trEPRtoolboxRootDir,trEPRtoolboxExampleDir));
	  
end

% TODO: Try to save the path using "savepath" (return 0 = OK, return 1 =
% error)

status = savepath;

if status
    fprintf('There were some problems with saving your Matlab search path.');
end

fprintf('\nSUCCESS!\n\n  Your trEPR toolbox, version %s, should be properly installed now.\n',trEPRtoolboxRevisionNumber);
fprintf('  For more information according to the toolbox simply typein "trEPRinfo".\n');

