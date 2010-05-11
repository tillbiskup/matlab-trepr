function trEPRinstall
% TRPERINSTALL  Install the trEPR toolbox (set Matlab path)

% Copyright (C) 2007 Till Biskup, <till@till-biskup.de>
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

fprintf('=========================================================================\n\n');
fprintf('  Welcome to the installation procedure of  \n\n');
fprintf('  trEPR, a Matlab toolbox for transient Electron Paramagnetic Resonance  \n\n');
fprintf('  Revision %s \n\n',trEPRtoolboxRevisionNumber);
fprintf('=========================================================================\n\n');
	
% First of all, check whether there is a version of the trEPR toolbox installed
% and if so, print out a short message and abort further processing
	
if ( findstr(path,'trEPR'))

	fprintf('PLEASE NOTE:\n\n  It seems as if you have already installed the trEPR toolbox.\n');
	fprintf('  Typein "trEPRinfo" to get some information about the installed version.\n\n');
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
	path(path,[trEPRtoolboxRootDir trEPRtoolboxBaseDir]);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxProgDir]);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxProgDir '/GUI']);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxProgDir '/IO']);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxProgDir '/preprocessing']);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxProgDir '/common']);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxDocDir]);
	path(path,[trEPRtoolboxRootDir trEPRtoolboxExampleDir]);
	  
end

% TODO: Try to save the path using "savepath" (return 0 = OK, return 1 =
% error)

status = savepath;

if status
    fprintf('There were some problems with saving your Matlab search path.');
end

fprintf('\nSUCCESS!\n\n  Your trEPR toolbox, version %s, should be properly installed now.\n',trEPRtoolboxRevisionNumber);
fprintf('  For more information according to the toolbox simply typein "trEPRinfo".\n');

