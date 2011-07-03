% Copyright (C) 2005,2006 Till Biskup
% 
% This file ist free software.
% 
%****f* file_handling.fsc2_files/trEPR_read_fsc2_file.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005,2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/01/11
% VERSION
%	$Revision: 391 $
% MODIFICATION DATE
%	$Date: 2007-06-27 15:39:15 +0100 (Mi, 27 Jun 2007) $
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
%	TREPR_READ_FSC2_FILE reads in an fsc2 file and returns the data from this file
%	together with additional parameters: the MW frequency and the field, scope, 
%	and time parameters.
%
%	Therefore it asks the user to provide a filename for an fsc2 file to read
%	and after checking whether the file exists reads this file and returns 
%	the data and the additional information in its output parameters.
%
%	Thus TREPR_READ_FSC2_FILE is a user interface to the low-level function
%	read_fsc2_file.m. For more details please typein 'help read_fsc2_file'.
%
% INPUT
%	currently there are no input parameters
%
% OUTPUT
%	data
%		NxM matrix containing the measured data
%
%	frequency
%		MW frequency the spectra were measured at
%
%	field_params
%		a 3x1 vector containing of three values, the "field parameters"
%
%		These field parameters are:
%
%			start_field
%				the start position of the field sweep given in Gauss (G)
%			end_field
%				the stop position of the field sweep given in Gauss (G)
%			field_step_width
%				the step width by which the field is swept given in Gauss (G)
%
%	scope_params
%		a 3x1 vector containing of three values, the "scope parameters"
%
%		These field parameters are:
%
%			sensitivity
%				the sensitivity of the scope (normally in mV)
%			time_base
%				the time base of the scope (normally in us)
%			averages
%				the number of averages that were collected for each time slice
%
%	time_params
%		a 3x1 vector containing of three values, the "time parameters"
%	
%		These time parameters are:
%
%			no_points
%				number of points of the time slice
%			trig_pos
%				position of the trigger pulse
%			length_ts
%				length of the time slice in microseconds
%
%	filename
%		string containing the filename of the fsc2 file that has been read in
%
%	trigger_pos
%		scalar containing the trigger position of the scope
%
%		identical with time_params(2) but provided for compatibility reasons
%
% EXAMPLE
%	To read in a fsc2 file just typein
%
%		[ data,freq,fp,sp,tp,filename,trig_pos ] = trEPR_read_fsc2_file
%
%	and the program will guide you interactively through the whole process of
%	reading in an fsc2 file it asks you for.
%
% DEPENDS ON
%	* read_fsc2_data
%	* global DEBUGGING
%
% PORTABILITY
%
%	The program is totally compatible with GNU Octave and MATLAB (TM)
%
% SOURCE

function [ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file

	fprintf ( '\n%% FUNCTION CALL: $Id: trEPR_read_fsc2_file.m 391 2007-06-27 14:39:15Z till $\n%% ' );


	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_read_fsc2_file" to get help.',nargin);

	end

	if ( nargout ~= 7 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_read_fsc2_file" to get help.',nargout);

	end

	% check for the availability of the routines we depend on

	if ( exist('read_fsc2_data.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'read_fsc2_data');

	end

	
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

	% Ask the user for a file name to read and if file name is valid, read data

	filename = ' ' ;				% set filename to empty value
								% the space is necessary not to confuse GNU Octave

	while (exist(filename) == 0)	% while there is no valid filename specified
								% This would be better done with a do...until loop
								% but silly MATLAB(R) doesn't support this...

		filename = input ( '\n% Please enter a filename of a fsc2 data file:\n   ', 's' );

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


	fprintf ( '\n%% File\n%% \t%s\n%% will be read...\n%%\n%% ', filename );
  
	[ data, frequency, field_params, scope_params, time_params ] = read_fsc2_data ( filename );
  		% open the file and read the data

	trigger_pos = time_params(2);
	% get trigger_pos out of time_params

%******