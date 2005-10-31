% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* auxilliary_routines/start_logging.m
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
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ logfilename ] = start_logging
%
% DESCRIPTION
%	This function is used to begin the logging of the further processing of a script file.
%	Therefore it first asks for a filename and checks for the existence of the given file.
%
%	The return value logfilename is optional.
%
% SEE ALSO
%	stop_logging
%
% SOURCE

function varargout = start_logging
  
  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n' );

  diary ('off')				% in case that the diary function is already started, stop it.

  proceed = 0;				% set variable for while condition to default value
  
  while (proceed == 0)		% while proceed is set to zero
  
    logfilename = input ( 'Please enter a filename for the log file (if empty, default will be used):\n   ', 's' );
    							% prompt the user for a filename for the log file

    if length( logfilename ) > 0	
							% If the user provided a filename
							
	  if exist( logfilename )
	  						% if the file still exists
	
	    answer = menu('The provided file exists. Do You really want to proceed?','Yes','No');
	   						% ask the user what to do now
	  
	    if answer == 1		% if user chose to proceed anyway
	  
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

      logfilename = [(datestr (now,30)),'.dat']
  							% generate logfile filename from current date and time ('now')
  							% formatted as string with 'T' as separator: YYYYMMDDTHHMMSS
  							
  	  proceed = 1;
  
    end						% end of if length(filename) condition
    
  end						% end while loop
  							
  fprintf ( '\nFile %s will be used as logfile for the current session...\n\n', logfilename );
  
  diary ( logfilename );	% start logging via the 'diary' function

  if nargout > 0			% if called with more than zero output arguments
  
	varargout(1) = { logfilename };

  end


  % once again for the log file:

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n' );

%******
