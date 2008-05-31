% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* general.logging/start_logging.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/24
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	diary, logging
%
% SYNOPSIS
%	[ logfilename ] = start_logging
%
% DESCRIPTION
%	This function is used to start logging of any further output that goes to the
%	Matlab(TM) workspace.
%
%	Therefore it first asks for a filename and checks for the existence
%	of the given file.
%
%	The return value logfilename is optional.
%
% INPUT
%	There are no input arguments at the moment
%
% OUTPUT
%	logfilename (OPTIONAL)
%		string containing the filename of the logfile the user has chosen
%
% EXAMPLE
%	To start logging all outputs just typein
%
%		[ logfilename ] = start_logging
%
% SEE ALSO
%	stop_logging
%
% SOURCE

function varargout = start_logging
	
	fprintf ( '\nFUNCTION CALL: $Id$\n\n' );

	% check for right number of input and output parameters

	if nargin ~= 0
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help stop_logging" to get help.',nargin);
			% get error if function is called with other than
			% zero input parameters
	end

	if nargout > 1
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help stop_logging" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter
	end

	diary ('off')				% in case that the diary function is already started, stop it.

	proceed = 0;				% set variable for while condition to default value
	
	while (proceed == 0)		% while proceed is set to zero
	
		logfilename = input ( 'Please enter a filename for the logfile:\n	 ', 's' );
									% prompt the user for a filename for the log file

		if length( logfilename ) > 0	
							% If the user provided a filename
							

			if (strcmp(logfilename,'..'))
  
				fprintf ( 'You have not entered a valid filename!\n\n' );
								% just print a short message and return to main loop
				logfilename = ' ';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
    
			end

			if (strcmp(logfilename,'.'))
  
				fprintf ( 'You have chosen to abort...\n\n' );
								% just print a short message and return to main loop
				logfilename = '';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
    								
   					return
    
			end

			if exist( logfilename )
								% if the file still exists
	
				answer = menu('The provided file exists and will be overwritten. Do You really want to proceed?','Yes','No');
		 						% ask the user what to do now
		
				if answer == 1		% if user chose to proceed anyway
		
				delete ( logfilename );
					
				proceed = 1;		% set condition for while loop so that the while loop will not
									% passed through once again
		
				else					% in the other case
		
					proceed = 0;		% go through the while loop once again

				end					% end if answer
	
			else					% if the file doesn't exist yet
		
				proceed = 1;			% set condition for while loop so that the while loop will not
									% passed through once again
	
			end					% end if exists
	
		else						% In case the user didn't provide a filename

			logfilename = [(datestr (now,30)),'.dat'];
								% generate logfile filename from current date and time ('now')
								% formatted as string with 'T' as separator: YYYYMMDDTHHMMSS
								
			proceed = 1;
	
		end						% end of if length(filename) condition
		
	end						% end while loop
								
	fprintf ( '\nFile\n	%s\nwill be used as logfile for the current session...\n\n', logfilename );
	
	fprintf ( '\nTIP: It''s a good idea to start this file with some comments\n     describing what it is all about.\n     Therefore you might typein your comment with leading ''%%'' character\n     at the beginning of each line.\n' );
	
	fprintf ( '\nNOTE: Below the following dashed line everything that appears at the\ncommand line goes into the log file until ''stop_logging'' is called.\n\n' );
	
	fprintf ( '---------------------------------------------------------------------------\n\n' );

	diary ( logfilename );	% start logging via the 'diary' function

	if nargout > 0			% if called with more than zero output arguments
	
	varargout(1) = { logfilename };

	end


	% once again for the log file:

	fprintf ( 'start_logging;\n%%\n%% FUNCTION CALL: $Id$\n%%' );

%******
