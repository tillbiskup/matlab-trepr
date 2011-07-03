% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* file_handling.ascii_save_data/ascii_save_spectrum.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/10
% VERSION
%	$Revision: 531 $
% MODIFICATION DATE
%	$Date: 2008-02-25 12:53:10 +0000 (Mo, 25 Feb 2008) $
% KEYWORDS
%	transient EPR, fsc2, ASCII save data
%
% SYNOPSIS
%	ascii_save_spectrum ( filename, spectrum, field_params, time_params, [frequency] )
%
% DESCRIPTION
%	This function saves an 1D spectrum as ASCII file with leading commentaries
%	and together with the values for the B_0 field axis.
%
%	This ASCII file whose name is provided as first input parameter starts
%	with a MATLAB(TM) comment (leading '%' sign at each line) including the
%	field and time parameters and if provided as optional fifth input argument
%	the frequency the time slice was recorded at.
%
%	The data itself are written as two columns, the time position as first
%	column, given in Gauss (%6.1f) and separated by a TAB the signal
%	values given in millivolts (%+14.12f). Given in parentheses is the output
%	format in c-style syntax for both columns respectively.
%
% INPUT PARAMETERS
%	filename
%		the name of the file the ASCII data should be saved in
%
%		In case this file still exists the user is asked interactively whether
%		to overwrite this file or to choose a different name. If the user
%		chooses to typein a different filename, this is checked as well for
%		existence and handled as before.
%
%	spectrum
%		a Nx1 (or 1xN) vector containing the data from the time slice
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
%		Normally this parameter is returned by the function trEPR_read_fsc2_file.
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
%		Normally this parameter is returned by the function trEPR_read_fsc2_file.
%
%	frequency
%		optional parameter for the frequency at which the time slice was recorded.
%
%		If this parameter is given the frequency will be saved in the leading
%		header of the output ASCII file.
%
% OUTPUT PARAMETERS
%	In the moment there are no output parameters
%
% EXAMPLE
%	If you want to save the B_0 spectrum spectrum with the field parameters fp and
%	the time parameters tp measured at the frequency freq to the file named 'sp.dat'
%	just typein:
%
%		ascii_save_spectrum ( 'sp.dat', spectrum, fp, tp, freq )
%
% SOURCE

function ascii_save_spectrum ( filename, spectrum, field_params, time_params, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id: ascii_save_spectrum.m 531 2008-02-25 12:53:10Z till $\n\n' );
	
	% check for right number of input and output parameters

	if ( nargin < 4 ) || ( nargin > 5)
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help ascii_save_spectrum" to get help.',nargin);
			% get error if function is called with other than
			% four input parameters
	end
	
	if nargin == 5
	
		frequency = varargin{1};
	
	end

	if nargout ~= 0
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help ascii_save_spectrum" to get help.',nargout);
			% get error if function is called with other than
			% zero output parameters
	end
	
	% check for correct format of the input parameters
	
	% FILENAME
	
	if ~isstr(filename)
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','filename');
			% get error if function is called with the wrong format of the
			% input parameter 'filename'
	
	elseif length(filename) == 0

		error('\n\tThe function is called with an empty string as the filename %s.\n\tPlease use "help ascii_save_spectrum" to get help.','filename');
			% get error if function is called with an empty 'filename'

	% SPECTRUM

	elseif ~isnumeric(spectrum)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','spectrum');
			% get error if function is called with the wrong format of the
			% input parameter 'spectrum'

	elseif ~isvector(spectrum)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','spectrum');
			% get error if function is called with the wrong format of the
			% input parameter 'spectrum'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	% OPTIONAL PARAMETER "FREQUENCY"

	elseif nargin == 5
		% in case function has been called with the optional fifth parameter
	
		if ~isnumeric(frequency)

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','frequency');
				% get error if function is called with the wrong format of the
				% input parameter 'frequency'
	
		elseif ~isscalar(frequency)

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_spectrum" to get help.','frequency');
				% get error if function is called with the wrong format of the
				% input parameter 'frequency'
				
		end

	end
	

	% check whether output file still exists
	
		% if the filename exists than the user will be asked whether he wants
		% to overwrite the file. Otherwise he has the possibility to typein a
		% different filename that will be checked as well for existence.
	
	if exist( filename )
		% if the file still exists
	
		menutext = sprintf('The file that is used by default to save the ascii spectrum to\n(%s) seems to exist.\nDo You really want to overwrite? Otherwise you can choose another file name.',filename);
	
		answer = menu(menutext,'Yes','No');
			% ask the user what to do now
	  
		if answer == 1
			% if user chose to proceed anyway
	  
			delete ( filename );
	  
		else					% in the other case
	  
			while ( length(filename) == 0)
				% as long as the user had not provided
				% a filename
  
			    filename = input ( 'Please enter another filename for the ASCII data to be saved in:\n   ', 's' );
    					% prompt the user for a filename for the log file

			    if length( filename ) > 0	
					% If the user provided a filename
							
					if exist( filename )
	  					% if the file still exists
	
						menutext = sprintf('The file you provided (%s) seems to exist.\nDo You really want to overwrite? Otherwise you can choose another file name.',filename);
	
						answer = menu(menutext,'Yes','No');
		   					% ask the user what to do now
	  
						if answer == 1
							% if user chose to proceed anyway
	  
							delete ( filename );
          
						else
							% in the other case
	  
							filename = '';
							% set filename to the empty string
							% thus going through the while-loop once again
						
						end
							% end if answer
	
					else	
						% if the file doesn't exist yet
	  
					end		% end if exist(filename)
					
				end		% end if length(filename) > 0
				
			end		% end while loop
			% here should go in some functionality that allows the user
			% to typein another file name, perhaps with displaying the
			% filename that still exists...

		end		% end if answer
	
	end		% end if exist(filename)
	
	
	% open file given by filename for write access
	
	fid=0;				% set file identifier to standard value
	
	while fid < 1 		% while file not opened
	
		[fid,message] = fopen(filename, 'wt');
						% try to open file 'filename' and return fid and message
		if fid == -1		% if there are any errors while trying to open the file
		
			error('\n\tFile %s could not be opened for write:\n\t%s', filename, message);
						% display the message from fopen
						
		end				% end "if fid"
		
	end					% end while loop

	% write header

	comment_char = '%';

	fprintf(fid, '%s This file has been written by the routine $Id: ascii_save_spectrum.m 531 2008-02-25 12:53:10Z till $\n', comment_char);
	fprintf(fid, '%s\n', comment_char);
	fprintf(fid, '%s Field parameters were:\n%s\tstart field: %i G\n%s\tstop field:  %i G\n%s\tstep width:   %2.1f G\n', comment_char,comment_char,min([field_params(1) field_params(2)]),comment_char,max([field_params(1) field_params(2)]),comment_char,abs(field_params(3)));
	fprintf(fid, '%s\n', comment_char);
	fprintf(fid, '%s Time parameters were:\n%s\tnumber of points: %i\n%s\ttrigger position: %i\n%s\tlength:           %i microseconds\n', comment_char,comment_char,time_params(1),comment_char,time_params(2),comment_char,time_params(3));
	fprintf(fid, '%s\n', comment_char);
	
	if exist('frequency') == 1

		fprintf(fid, '%s Frequency was:\n%s\t%7.5f GHz\n', comment_char, comment_char, frequency);
		fprintf(fid, '%s\n', comment_char);
	
	end
	
	fprintf(fid, '%s Description of the data:\n', comment_char);
	fprintf(fid, '%s\t1st column: B_0 field in G\n', comment_char);
	fprintf(fid, '%s\t2nd column: signal intensity in mV\n', comment_char);
	fprintf(fid, '%s\n', comment_char);
	

	% write data
	
	field_boundaries = [ field_params(1) field_params(2) ];
	field = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
	
	j = 1;
	
	while (j<=length(spectrum))
	
		fprintf(fid, '%7.2f\t%+016.12f\n',field(j),spectrum(j));
		j = j + 1;
		
	end;
	
	% save close file

	while fid > 2
		% the fids 0, 1 and 2 are reserved for special purposes (input, output, error)
		% that's why every other file identifier (file handle) has a number > 2
	
		% try to close the file
		status = fclose(fid);

		% test whether the closing was successful
		if status == -1
			% if there are any errors while trying to close the file
		
			error('\n\tFile %s could not be closed:\n\t%s', filename, status);
						% display the message from fclose
						
		elseif status == 0
		
			% set file identifier to exit while loop
			fid = -1;
						
		end				% end "if fid"
		
	end					% end while loop
	

%*******