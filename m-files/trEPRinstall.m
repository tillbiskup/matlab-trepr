% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/trEPRinstall.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/02/02
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	trEPR toolbox, installation, set paths
%
% SYNOPSIS
%	trEPRinstall
%
% DESCRIPTION
%	The function TREPRINSTALL helps the user installing the trEPR toolbox
%	in MATLAB(TM), e.g. setting the paths etc.
%
% INPUT PARAMETERS
%	There are no input parameters at the moment.
%
% OUTPUT PARAMETERS
%	There are no input parameters at the moment.
%
% COMPATIBILITY
%	This program is specially designed for use with MATLAB(TM)
%
% EXAMPLE
%	To install the trEPR toolbox simply typein
%
%		trEPRinstall
%
% SOURCE

function trEPRinstall

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPRinstall" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPRinstall" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in
	
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
	
	if ( exist('trEPRinfo') == 2)
		
		fprintf('PLEASE NOTE:\n\n  It seems as if you have already installed the trEPR toolbox.\n');
		fprintf('  Typein "trEPRinfo" to get some information about the installed version.\n\n');
		return;
		
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
		path(path,[trEPRtoolboxRootDir trEPRtoolboxDocDir]);
		path(path,[trEPRtoolboxRootDir trEPRtoolboxExampleDir]);
	  
	else
	
		fprintf('You need to call this program from the directory it resides in...\n\n');
		return;
	
	end

	fprintf('\nSUCCESS!\n\n  Your trEPR toolbox, version $s, should be properly installed now.\n',trEPRtoolboxRevisionNumber);
	fprintf('  For more information according to the toolbox simply typein "trEPRinfo".\n');

%******
