% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* general.UIfunctions/UIAskForNewFileName.m
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
%	user interface, UI, new filename
%
% SYNOPSIS
%	UIAskForNewFileName
%
% DESCRIPTION
%	UI function to ask a user for a new filename and check for the existence
%	of that file. In case it exists the user is asked whether to overwrite the file
%	or not. In case he chooses to overwrite, the existing file will be deleted.
%
% INPUT PARAMETERS
%	There are no input parameters at the moment
%
% OUTPUT PARAMETERS
%	filename
%		string holding the filename of the (new) file its name is provided
%		by the user
%
% EXAMPLE
%	For asking a user to type in a filename and to check for the existence of the
%	corresponding file type
%
%		[ filename ] = UIAskForNewFileName;
%
%	The user will see than a prompt asking for a filename.
%
%	IMPORTANT: The user is given the opportunity to abort the procedure. In this
%	case the function returns an empty string as a filename. Therefore, all 	scripts
%	and functions that make use of this function need to check for the returned
%	value and proceed according to its result.
%
% SOURCE

function [ filename ] = UIAskForNewFileName

	fprintf('\n%% FUNCTION CALL: $Id: UIAskForNewFileName.m 387 2007-06-27 11:47:46Z till $\n%%');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help UIAskForNewFileName" to get help.',nargin);

	end

	if ( nargout ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help UIAskForNewFileName" to get help.',nargout);

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


	proceed = 0;				% set variable for while condition to default value
	
	while (proceed == 0)		% while proceed is set to zero
	
		filename = input ( '\n% Please enter a filename.\n% To abort, typein ''.'' instead of a filename:\n	 ', 's' );
									% prompt the user for a filename for the log file

		if length( filename ) > 0	
							% If the user provided a filename
							
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

			if exist( filename )
								% if the file still exists
	
				answer = menu('The provided file exists and will be overwritten. Do You really want to proceed?','Yes','No');
		 						% ask the user what to do now
		
				if answer == 1		% if user chose to proceed anyway
		
					delete ( filename );
					
					proceed = 1;		% set condition for while loop so that the while loop will not
									% passed through once again
		
				else					% in the other case
		
					proceed = 0;		% go through the while loop once again

				end					% end if answer
	
			else					% if the file doesn't exist yet
		
				proceed = 1;			% set condition for while loop so that the while loop will not
									% passed through once again
	
			end					% end if exists
	
	
		end						% end of if length(filename) condition
		
	end						% end while loop
	
return;

%******
