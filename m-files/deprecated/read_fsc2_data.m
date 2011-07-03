% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* file_handling.fsc2_files/read_fsc2_data.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/09/28
% VERSION
%	$Revision: 703 $
% MODIFICATION DATE
%	$Date: 2008-07-24 15:13:49 +0100 (Do, 24 Jul 2008) $
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ DATA, FREQUENCY, FIELD_PARAMS, SCOPE_PARAMS, TIME_PARAMS ] = read_fsc2_data ( FILENAME )
%
% DESCRIPTION
%	Open the FSC2 file FILENAME, look for some parameters necessary
%	for the further data analysis that are written in the leading
%	commentary and return a matrix DATA of the raw data, a variable
%	FREQUENCY with the frequency the measurement was performed and
%	the vectors FIELD_PARAMS, SCOPE_PARAMS and TIME_PARAMS.
%
%	A FSC2 file consists of the FSC2 program used for the data
%	acquisition in the first part of the file, marked as a MATLAB (TM)
%	comment with leading "%" at every line and after that the data
%	as one long column. Advantages of this format are that the program
%	used for data acquisition is in the same file as the data and that
%	the data are stored in the file directly after reading out from the
%	oscilloscope. This minimizes data loss in the case of any computer
%	problem.
%
%	More information about FSC2 can be found at its authors page in the
%	internet:
%
%		http://www.physik.fu-berlin.de/~toerring/fsc2.phtml
%
%	If the measurement was taken from higher to lower magnetic field
%	the returned matrix is rearranged to hold the time traces (rows)
%	in increasing magnetic field strength.
%
% INPUT
%	filename
%		string containing the filename of the fsc2 file that has to be read in
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
% EXAMPLE
%	To read in the fsc2 file some_spectrum.dat just typein
%
%		[ data, freq, fp, sp, tp ] = read_fsc2_data ( 'some_spectrum.dat' )
%
% TODO:
%
%   * Read out the variable "Number of runs" and behave as necessary
%	  if runs > 1
%
% SOURCE

function [ data, frequency, field_params, scope_params, time_params ] = read_fsc2_data ( filename )
	
	fprintf ( '\n%% FUNCTION CALL: $Id: read_fsc2_data.m 703 2008-07-24 14:13:49Z till $\n%% ' );

	% check for the right number of input and output parameters

	if nargin ~= 1			% Check number of input arguments.
	
	error('The function is called with the wrong number (%i) of input arguments.\nPlease use "help <function>" to get help.',nargin);
		% get error if function is called with other than
		% one input parameter

	end

	if nargout ~= 5		% Check number of output arguments.
	
		fprintf('\nWARNING: Function called with too less return values.\n				 Errors might occur if we were called inside a program.\n				 To see how we shall be called type in \"help read_fsc2_data\".\n')

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

	global status;

	% save opening of the file that's name is provided by the variable 'filename'

	if ( exist( filename )	== 2 )
							% if the provided file exists

		fid=0;				% set file identifier to standard value
		while fid < 1 		% while file not opened
			[fid,message] = fopen(filename, 'r');
								% try to open file 'filename' and return fid and message
			if fid == -1		% if there are any errors while trying to open the file
				disp(message)		% display the message from fopen
			end				% end "if fid"
		end					% end while loop
		
	else					% If the file provided by filename does not exist

		% assign empty values to all output parameters
		
		data=[];frequency=[];field_params=[];scope_params=[];time_params=[];

		% display an error message and abort further operation

		error('\n\tFile %s not found\n\tAbort further operation...', filename);
	
	end;
	
	% read the leading commentary of the fsc2 file line by line
	% and extract the necessary parameters:
	
	read = '%';					% variable 'read' set to '%' to initially
									% match the while loop condition
									
	is_fsc2_file = 0;				% initialize variable with default value;
	
	while index (read, '%' ) == 1	% while read line starts with '%'
	
		read = fgetl ( fid );			% linewise read of file
		
		
		% check for the file whether it is an fsc2 file or not
		% this is done by the criterium that in an original fsc2 file
		% within the first three lines there is one line containing the string
		% "#!/usr/local/bin/fsc2"
 	
		fsc2_file_marker = findstr ( read, '/bin/fsc2' );
	
		if ( length(fsc2_file_marker) > 0 )
	
			is_fsc2_file = 1;
	
		end
	
		% read parameters from the file
	
		parameter = read_parameter_from_fsc2 ( read, 'Start field' );
								% calling internal function (see below) to check whether
								% the desired parameter stands in the actual line
								
		if isnumeric(parameter) ~= 0	% the function "read_parameter_from_fsc2" returns "NaN" if
								% the parameter is not found in the actual line
								% Therefore check whether "parameter" is numeric
			start_field = parameter;	% and in this case set the variable
		
		end

		% repeat the above described for the other parameters

		parameter = read_parameter_from_fsc2 ( read, 'End field' );
		if isnumeric(parameter) ~= 0
			end_field = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Field step width' );
		if isnumeric(parameter) ~= 0
			field_step_width = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Sensitivity' );
		if isnumeric(parameter) ~= 0
			sensitivity = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Number of averages' );
		if isnumeric(parameter) ~= 0
			averages = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Time base' );
		if isnumeric(parameter) ~= 0
			time_base = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Number of points' );
		if isnumeric(parameter) ~= 0
			no_points = parameter;
		end

		parameter = read_parameter_from_fsc2 ( read, 'Trigger position' );
		if isnumeric(parameter) ~= 0
			trigger_pos = parameter;
		end
	
		parameter = read_parameter_from_fsc2 ( read, 'Slice length' );
		if isnumeric(parameter) ~= 0
			slice_length = parameter;
		end
	
		parameter = read_frequency_from_fsc2 ( read, '9' );
		if isnumeric(parameter) ~= 0
			frequency = parameter;
		end
	
		parameter = read_parameter_from_fsc2 ( read, 'MW frequency' );
		if isnumeric(parameter) ~= 0
			frequency = parameter;
		end
	
	end								% end of while loop
	
	close_file( fid );					% calling internal function (see below) to close the file

	if ( is_fsc2_file == 0 )

	% in the case the file read is no fsc2 file

	% assign empty values to all output parameters
		
		data='';frequency='';field_params='';scope_params='';time_params='';

	% display an error message and abort further operation

	%	error('\n%% \tHmmm... %s does not look like an fsc2 file...\n%% \tAbort further operation...', filename);
	
		status = 1;
	
		warning('trEPR:WrongFileFormat','Wrong format of the input file');
		
		return;
		
	end

	
	% write parameters grouped to vectors as return values of the function
	field_params = [ start_field, end_field, field_step_width ];
	scope_params = [ sensitivity, time_base, averages ];
	time_params	= [ no_points, trigger_pos, slice_length ];
	
	% print table with parameters to output
	
	fprintf('\n%% Parameters of the file just read:\n%% ');
	fprintf('\n%%   magnetic field parameters:\n%% ');
	fprintf('    field start:       %6.1f G\n%%     field stop:        %6.1f G\n%%     field step width:  %2.2f G\n%% ', field_params);
	fprintf('\n%%   scope parameters:\n%% ');
	fprintf('    sensitivity:       %i e-06 s\n%%     time base:         %i e-06 s\n%%     averages:          %i\n%% ', scope_params);
	fprintf('\n%%   time parameters:\n%%');
	fprintf('     No of points:      %i\n%%     trigger position:  %i\n%%     slice length:      %i us\n%%', time_params);
	fprintf('\n%%   MW frequency:        %1.5f GHz\n%% ', frequency);
	
	% calculations for the dimension of the 2D-matrix for finally storing the data
	
	field_width = (end_field - start_field) / field_step_width;
			% the field width is calculated by the difference between
			% upper and lower field boundaries divided through the
			% step width between two adjacent recorded time traces.
			% field_width is always positive cause of the negative sign
			% of the variable field_step_width in case of measurement
			% from high to low field

	hightolow = 0;						% set "boolean" variable to the default value (see below)

	if field_step_width < 0				% if measured from higher to lower fields
		hightolow = 1;					% set "boolean" variable
	end								% end if
	
	
	% now read the actual data
	
	raw_data = load ( filename );		% read fsc2 data file (automatically ignore comments)

	% ppscan means "points per scan"
	% As fsc2 writes the data as one long column, even if you store several
	% scans in one file, you should know how many values belong to one scan.
	
	ppscan = (field_width + 1) * no_points;
	
	% countViF means "count of values in file"
	[countViF, cols] = size(raw_data);


	% Test whether raw_data size fits in dimensions calculated by parameters 
	% of the input file.
	% That can happen if a measurement has been aborted before its completion.
	% Another situation would be to have more than one scan stored in one file.

	% If the number of values of the data read in is less than the number of
	% values of one scan, meaning that the measurement was aborted before 
	% one scan was finished, print a warning and truncate the field parameters
	
	if ( countViF < ppscan )
	
        fprintf( ...
          [ ...
            '\n' ...
            'WARNING: Data do not match the dimensions given by the parameters!\n' ...
            '         Field parameters adjusted to fix data...\n' ...
          ] ...
        );

		% set field_width to new value

		field_width = abs ( round ( length(raw_data) / no_points ) * field_step_width );
	
		% set field parameters to new values

		end_field = start_field + ( ( ( field_width / field_step_width ) + 1 ) * abs(field_step_width));
		field_params = [ start_field, end_field, field_step_width ];
	
		fprintf('\nadjusted magnetic field parameters:\n');
		fprintf('field start:\t\t%4.1f G\nfield stop:\t\t%4.1f G\nfield step width:\t%2.2f G\n', field_params);
	
        % for faster computing of octave initialize empty matrix
        % with the above calculated final dimensions
        matrix = zeros (field_width, no_points);

        for i = 1:(field_width+1)
          matrix (i,:) = raw_data(1+((i-1)*no_points):i*no_points)';
        end
		
	% If the number of values of the data read in exceeds the number of values
	% of one scan, meaning that there is more than one scan stored in the file,
	% in a first step, try to get out, how many complete scans are there 
	% in the file, and in a second step, average over the scans.

	elseif ( countViF > ppscan )
	
	  % get number of completed scans
	  num_scans = floor( countViF/ppscan );

      % for faster computing of octave initialize empty matrix
      % with the above calculated final dimensions
      matrix = zeros (field_width+1, no_points);

      fprintf( ...
        [ ...
          '\n' ...
          'WARNING: There seem to be %i complete scans saved in the file.\n' ...
          '         These scans will be averaged and the average returned...\n' ...
        ], ...
        num_scans ...
      );
	  
	  sum_matrix = matrix;
	  
	  for k = 1 : num_scans
	  
        for l = 1:(field_width+1)
          matrix (l,:) = raw_data(1+((l-1)*no_points):l*no_points)';
        end
	    
	    sum_matrix = sum_matrix + matrix;
	  
	  end
	  
	  matrix = sum_matrix / num_scans;

	elseif countViF == ppscan

      for i = 1:(field_width+1)
        matrix (i,:) = raw_data(1+((i-1)*no_points):i*no_points)';
      end
      
    end


	% return the data as matrix

	if hightolow == 1					% if measured from higher to lower fields
		data = flipud ( matrix );			% reverse rows of the matrix containing the data
	else
		data = matrix;					% otherwise return the data as recorded by fsc2
	end

	status = 0;

	% end of main function
	
	
%******


%##############################################################
% SUBFUNCTIONS

%****if* read_fsc2_data/open_file
%
% SYNOPSIS
%	FID = open_file ( FILENAME )
%
% DESCRIPTION
%	Open file FILENAME for read and check whether file is openend
%	if not, an error message is printed and further evaluation of the script
%	is aborted
%
% SOURCE

function fid = open_file ( filename )
 
	fid = 0;							% set file identifier to an initial value
	
	while fid < 1						% while no file is opened (otherwise "fid == 1")
	
		[fid,message] = fopen ( filename, 'r' );
										% open file FILENAME for read
		
		if length(message) > 0			% if opening of the file FILENAME fails
										% exact: if
		
			fprintf( message );				% print message MESSAGE
			error ( 'File %s could not be opened', filename )
											% and abort the further evaluation of the script
			
		end								% end if
		
	end								% end while

%******

%****if* read_fsc2_data/close_file
%
% SYNOPSIS
%	STATUS = close_file ( FID )
%
% DESCRIPTION
%	Close the file with the handle FID.
%
% SOURCE
	
function status = close_file ( fid )
	
	% close file
	
	status = fclose ( fid );

	% end subfunction close_file
	
%******

%****if* read_fsc2_data/read_parameter_from_fsc2
%
% SYNOPSIS
%	VALUE = read_parameter_from_fsc2 ( STRING, DESCRIPTION )
%
% DESCRIPTION
%	Check whether the string STRING contains the substring DESCRIPTION
%	and in this case return the value VALUE that is printed at a defined
%	position behind the substring DESCRIPTION in the leading commentary
%	of the fsc2 data file.
%
%	Parameter values are stored in a FSC2 file as "key=value" pairs.
%	This allows to access them easily.
%
% SOURCE
	
function value = read_parameter_from_fsc2 ( string, description )


	if index ( string, description ) == 3	
		% The string DESCRIPTION is contained more than once
		% in the leading commentary block of the fsc2 data file.
		% Therefore the condition here set is that the string
		% DESCRIPTION starts at position 3 of the string STRING.
		%
		% ATTENTION: The function INDEX is not a native MATLAB(R)
		% function and is therefore implemented in the file "index.m"

		res = substr ( string, 23 );
			% The value described by DESCRIPTION has a fixed position
			% from left in the fsc2 file - it starts at position 23
			% This position could be affected by further changes of the
			% fsc2 program but due to the loss of regexp functionality
			% in Octave this seems to be the simplest way for the moment.

		contains_spaces = findstr ( res, ' ' );
			% If the string RES contains whitespace characters
			% (normally at the end of the string)
			% than the positions of the whitespace characters
			% are elements of CONTAINS_SPACES

		if length(contains_spaces) > 1
			% if CONTAINS_SPACES is not empty

		res = substr ( res, 1, contains_spaces(2)-2 );
			% res is overwritten with its substring, starting at the first
			% position and ending at the first position of whitespace character
						
		end			% end if
		
		value = str2num( res );	
			% the value (string) is converted to a number
		
	else		
		% If the string DESCRIPTION is not found in the string STRING
		% or if DESCRIPTION starts not at position 3 of STRING
	
		value = 'NaN';
			% set the return variable "value" to a defined nonnumeric value
		
	end				% end if

	% end subfunction read_parameter_from_fsc2
		
%******


%****if* read_fsc2_data/read_frequency_from_fsc2
%
% SYNOPSIS
%	FREQUENCY = read_frequency_from_fsc2 ( STRING, SUBSTRING )
%
% DESCRIPTION
%	Check whether the string STRING contains the substring SUBSTRING
%	and in this case return the value VALUE that is printed at 	a defined
%	position behind the substring SUBSTRING in the leading commentary
%	of the fsc2 data file.
%
% SOURCE
	
function frequency = read_frequency_from_fsc2 ( string, substring )

	if index ( string, substring ) == 3	
		% The string SUBSTRING is contained more than once
		% in the leading commentary block of the fsc2 data file.
		% Therefore the condition here set is that the string
		% SUBSTRING starts at position 3 of the string STRING.
		%
		% ATTENTION: The function INDEX is not a native MATLAB(R)
		% function and is therefore implemented in the file "index.m"

		res = substr ( string, 5 );
			% The value described by SUBSTRING has a fixed position
			% from left in the fsc2 file - it starts at position 3 but
			% contains a comma instead of a dot - so it cannot be
			% converted to a number by 'str2num'. Workaround: Read out
			% the decimal places and add via string concatenation the '9.'
			% afterwards.
			% This position could be affected by further changes of the
			% fsc2 program but due to the loss of regexp functionality
			% in Octave this seems to be the simplest way for the moment.

		contains_spaces = findstr ( res, ' ' );
			% If the string RES contains whitespace characters
			% (normally at the end of the string)
			% than the positions of the whitespace characters
			% are elements of CONTAINS_SPACES

		if length(contains_spaces) > 0
			% if CONTAINS_SPACES is not empty

			res = substr ( res, 1, contains_spaces(1)-1 );
				% res is overwritten with its substring, starting at the first
				% position and ending at the first position of whitespace character
			
		end						% end if
			
		position_of_G = index ( res, 'G' );
			% If the string RES contains something as 'G' or 'GHz'
			% (at the end of the string)
			% than the starting position of this string
			% is written to POSITION_OF_G
			
		if ( position_of_G > 0 )
			% if POSITION_OF_G is not empty
			
			res = substr ( res, 1, position_of_G-1 );
				% res is overwritten with its substring, starting at the first
				% position and ending at the position of the 'G' character
			
		end
			
		res = ['9.', res];
 
		frequency = str2num( res );		% the value (string) is converted to a number
			
	else							% If the string DESCRIPTION is not found in the string STRING
		% or if DESCRIPTION starts not at position 3 of STRING
		
		frequency = 'NaN';			% set the return variable "value" to a defined nonnumeric value
			
	end							% end if

	% end subfunction read_parameter_from_fsc2
		
%******
