% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* general.UIfunctions/UIAskForExistingFileName.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/25
% VERSION
%	$Revision: 387 $
% MODIFICATION DATE
%	$Date: 2007-06-27 12:47:46 +0100 (Mi, 27 Jun 2007) $
% KEYWORDS
%	user interface, UI, existing filename
%
% SYNOPSIS
%	UIAskForExistingFileName
%
% DESCRIPTION
%	UI function to ask a user for an existing filename and check for the existence
%	of that file
%
% INPUT PARAMETERS
%	There are no input parameters at the moment
%
% OUTPUT PARAMETERS
%	filename
%		string holding the filename of the (existing) file its name is provided
%		by the user
%
% EXAMPLE
%	For asking a user to type in a filename and to check for the existence of the
%	corresponding file type
%
%		[ filename ] = UIAskForExistingFileName;
%
%	The user will see than a prompt asking for a filename.
%
%	IMPORTANT: The user is given the opportunity to abort the procedure. In this
%	case the function returns an empty string as a filename. Therefore, all 	scripts
%	and functions that make use of this function need to check for the returned
%	value and proceed according to its result.
%
% SOURCE

function [ filename ] = UIAskForExistingFileName

	fprintf('\n%% FUNCTION CALL: $Id: UIAskForExistingFileName.m 387 2007-06-27 11:47:46Z till $\n%%');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help UIAskForExistingFileName" to get help.',nargin);

	end

	if ( nargout ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help UIAskForExistingFileName" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in

	
	% Find out whether we are called by MATLAB(TM) or GNU Octave

	if exist('discriminate_matlab_octave')
		% let's check whether the routine performing the discrimination
		% is available...

	    program = discriminate_matlab_octave;
	    
	else
		% that means if the variable "program" isn't set yet and the routine
		% performing the discrimination isn't available...
	
		fprintf('\n%% Sorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\n%% This function will behave as if it is called within MATLAB(TM)...\n%% Be aware: In the case that is not true you can run into problems!');
		
		program = 'Matlab';
			
		% set variable to default value
	
	end;

	% Ask the user for a file name to read and if file name is valid, return it

	filename = ' ' ;				% set filename to empty value
								% the space is necessary not to confuse GNU Octave

	while ((exist(filename) == 0))
		% while there is no valid filename specified
		% This would be better done with a do...until loop
		% but silly MATLAB(R) doesn't support this...

		filename = input ( '\n% Please enter a filename.\n% To abort, typein ''.'' instead of a filename:\n   ', 's' );

		if (length( filename ) > 0)	% If the user provided a filename

			if program == 'Octave'		% if we're called by GNU Octave (as determined above)
  
				filename = tilde_expand ( filename );
  								% expand filenames with tilde
  	
			end						% end if program == 'Octave'

			if (strcmp(filename,'..'))
  
				fprintf ( '%% You have not entered a valid filename!\n\n' );
								% just print a short message and return to main loop
				filename = ' ';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
    
			end

			if (strcmp(filename,'.'))
  
				fprintf ( '%% You have chosen to abort...\n\n' );
								% just print a short message and return to main loop
				filename = '';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
    								
    				return
    
			end
  
			if (exist(filename) == 0)
  
				fprintf ( '%% File not found!\n' );
    
			end

		else							% In case the user didn't provide a filename

			fprintf ( '%% You have not entered any filename!\n\n' );
								% just print a short message and return to main loop
			filename = ' ';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
  
		end

	end		% end of while exist(filename) loop
	
return;

%******
