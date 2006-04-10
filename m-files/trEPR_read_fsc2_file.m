% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* user_routines/trEPR_read_fsc2_file.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/01/11
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% DERIVED FROM
%	script_read_file.m
% KEYWORDS
%	MATLAB(R), GNU Octave, transient EPR, fsc2, read file
%
% SYNOPSIS
%	[ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file
%
% DESCRIPTION
%
%	TREPR_READ_FSC2_FILE prompts for a user provided filename and after checking whether the file
%	exists reads this file and returns the data and some additional information.
%
% INPUT
%	no input parameters
%
% OUTPUT
%	data
%	frequency
%	field_params
%	scope_params
%	time_params
%
%	filename
%	trigger_pos
%
% DEPENDS ON
%	program
%	DEBUGGING
%
% PORTABILITY
%
%	The program is totally compatible with GNU Octave and MATLAB (TM)
%
% SOURCE

function [ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$' );

  % set some global variables

  global program;
  global DEBUGGING;
	
	if (length(program) == 0)
		% if the variable "program" is not set, that means the routine isn't called
		% yet...

		if exist('discriminate_matlab_octave')
			% let's check whether the routine performing the discrimination
			% is available...

		    program = discriminate_matlab_octave;
	    
		else
			% that means if the variable "program" isn't set yet and the routine
			% performing the discrimination isn't available...
	
			fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\nBe aware: In the case that is not true you can run into problems!');
		
			program = 'Matlab';
			
			% set variable to default value
	
		end;
	
	end;

  % Ask the user for a file name to read and if file name is valid, read data

  filename = ' ' ;				% set filename to empty value
								% the space is necessary not to confuse GNU Octave

  while (exist(filename) == 0)	% while there is no valid filename specified
								% This would be better done with a do...until loop
								% but silly MATLAB(R) doesn't support this...

	filename = input ( '\nPlease enter a filename of a fsc2 data file:\n   ', 's' );

	if (length( filename ) > 0)	% If the user provided a filename

      if program == 'Octave'		% if we're called by GNU Octave (as determined above)
  
		filename = tilde_expand ( filename );
  								% expand filenames with tilde
  	
	  end						% end if program == 'Octave'
  
	  if (exist(filename) == 0)
  
		fprintf ( 'File not found!' );
    
	  end
  
	else							% In case the user didn't provide a filename

	  fprintf ( 'You have not entered any file name!\n\n' );
								% just print a short message and return to main loop
	  filename = 'foo.bar';
    								% set a default filename for the 'exist(filename)' test
    								% needs a filename and cannot work with an empty string
  
	end

  end		% end of while exist(filename) loop


  fprintf ( '\nFile\n\t%s\nwill be read...\n\n', filename );
  
  [ data, frequency, field_params, scope_params, time_params ] = read_fsc2_data ( filename );
  								% open the file and read the data
  trigger_pos = time_params(2);	% get trigger_pos out of time_params


  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nEND OF $RCSfile$\n');
  end;

%******