% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* file_handling.ascii_read_data/ascii_read_2Dspectrum.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/06/21
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, ASCII read data
%
% SYNOPSIS
%	[ spectrum, field_params, time_params, frequency ] = ascii_read_2Dspectrum ( filename )
%
% DESCRIPTION
%	This function reads the time slices that are saved with the function 
%	ascii_save_2Dspectrum.m and returns the field and time parameters 
%	together with the data.
%
% INPUT PARAMETERS
%	filename
%		string containing the filename of the ASCII file containing the time slice
%		saved with the function ascii_save_2Dspectrum that has to be read in
%
% OUTPUT PARAMETERS
%	spectrum
%		NxM matrix containing the intensity values (in mV) of the time slice at the 
%		given field position.
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
%	frequency
%		frequency at which the time slice was recorded.
%
% EXAMPLE
%	To read the spectrum from the file 'filename' and get the spectrum (sp), the
%	field parameters (fp), time parameters (tp), and the frequency (f), just typein:
%
%		[ sp, fp, tp, f ] = ascii_read_2Dspectrum ( filename )
%
% SOURCE

function [ spectrum, field_params, time_params, frequency ] = ascii_read_2Dspectrum ( filename )

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help ascii_read_2Dspectrum" to get help.',nargin);

	end

	if ( nargout < 2 ) || ( nargout > 5 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help ascii_read_2Dspectrum" to get help.',nargout);

	end
	
	% check for correct format of the input parameters
	
	% FILENAME
	
	if ~isstr(filename)
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help read_fsc2_data" to get help.','filename');
			% get error if function is called with the wrong format of the
			% input parameter 'filename'
	
	elseif length(filename) == 0

		error('\n\tThe function is called with an empty string as the filename.\n\tPlease use "help read_fsc2_data" to get help.','filename');
			% get error if function is called with an empty 'filename'

	end

	% check for the availability of the routines we depend on
	
	if ( exist('index.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'index');
	
	elseif ( exist('substr.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'substr');
	
	end


	% save opening of the file that's name is provided by the variable 'filename'

	if ( exist( filename )	== 2 )
		% if the provided file exists

		% set file identifier to standard value
		fid=0;				

		while fid < 1
			% while file not opened

			% try to open file 'filename' and return fid and message
			[fid,message] = fopen(filename, 'r');

			if fid == -1
				% if there are any errors while trying to open the file

				% display the message from fopen
				disp(message)
				
			end
			% end "if fid"
		end
		% end while loop
		
	else	
		% If the file provided by filename does not exist

		% assign empty values to all output parameters
		spectrum=[];field_params=[];time_params=[];frequency=[];

		% display an error message and abort further operation
		error('\n\tFile %s not found\n\tAbort further operation...', filename);
	
	end;
	
	% read the leading commentary of the fsc2 file line by line
	% and extract the necessary parameters:
	
	read = '%';					% variable 'read' set to '%' to initially
									% match the while loop condition
									
	is_right_file = 0;				% initialize variable with default value;
	
	while index (read, '%' ) == 1	% while read line starts with '%'
	
		read = fgetl ( fid );			% linewise read of file
		
		
		% check for the file whether it is written with the function
		% ascii_save_spectrum or not.
		% This is done by the criterium that the first line of such a file would
		% contain the SVN ID tag of the version of the function, starting with
		% "$ID: ascii_save_2Dspectrum"
 	
		file_marker = findstr ( read, '$Id: ascii_save_2Dspectrum.m' );
	
		if ( length(file_marker) > 0 )
	
			is_right_file = 1;
	
		end

		if index(read,'start field:') > 0
		
			start_field = str2num( substr( read, index(read,':')+2, (length(read)-index(read,':')-2) ) );
		
		elseif index(read,'stop field:') > 0
		
			end_field = str2num( substr( read, index(read,':')+2, (length(read)-index(read,':')-2) ) );
		
		elseif index(read,'step width:') > 0
		
			field_step_width = str2num( substr( read, index(read,':')+2, (length(read)-index(read,':')-2) ) );
		
		elseif index(read,'number of points:') > 0
		
			no_points = str2num( substr( read, index(read,':')+2, (length(read)-index(read,':')) ) );
		
		elseif index(read,'trigger position:') > 0
		
			trigger_pos = str2num( substr( read, index(read,':')+2, (length(read)-index(read,':')) ) );
		
		elseif index(read,'length:') > 0
		
			slice_length = str2num( substr( read, index(read,':')+2, (index(read,'microseconds')-index(read,':')-2) ) );
		
		elseif index(read,'GHz') > 0
		
			frequency = str2num( substr( read, 2, index(read,'GHz')-2 ) );
		
		end
	
	end								% end of while loop
	
	fclose( fid );					% calling internal function (see below) to close the file

	if ( is_right_file == 0 )
		% in the case the file read is not written with the function
		% ascii_save_spectrum

		% assign empty values to all output parameters
		spectrum=[];field_params=[];time_params=[];frequency=[];	

		% display an error message and abort further operation
		error('\n\tHmmm... %s does not look like a file\n\twritten with the function ascii_save_spectrum...\n\tAbort further operation...', filename);
	
	end

	
	% write parameters grouped to vectors as return values of the function
	field_params = [ start_field, end_field, field_step_width ];
	time_params	= [ no_points, trigger_pos, slice_length ];
	
	% print table with parameters to output
	
	fprintf('\nParameters of the file just read:\n')
	fprintf('\nmagnetic field parameters:\n');
	fprintf('\tfield start:      %i G\n\tfield stop:       %i G\n\tfield step width: %2.2f G\n', field_params);
	fprintf('\ntime parameters:\n');
	fprintf('\tNo of points:     %i\n\ttrigger position: %i\n\tslice length:     %i us\n', time_params);
	fprintf('\nMW frequency:             %1.5f GHz\n', frequency);


	spectrum = load ( filename );		% read data file (automatically ignore comments)

%******

