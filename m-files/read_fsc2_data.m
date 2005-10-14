% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/read_fsc2_data.m
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
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ DATA, TRIGGER_POS ] = read_fsc2_data ( FILENAME )
%
% DESCRIPTION
%	This function opens the file FILENAME, looks for some
%	parameters necessary for the further data analysis that
%	are written in the leading commentary and returns a matrix
%	DATA of the raw data and a variable TRIGGER_POS with the position
%	of the trigger pulse in the time slice.
%
%	If the measurement was taken from higher to lower magnetic field
%	the returned matrix is rearranged to hold the time traces (rows)
%	in increasing magnetic field strength.
%
% TODO:
%	Read out the variable "Number of runs" and behave as necessary if runs > 1
%
%	Read out other parameters as "Sensitivity" and "Time base" for axis labels...
%
% SOURCE

function [ data, trigger_pos ] = read_fsc2_data ( filename )

  disp ( '$RCSfile$, $Revision$, $Date$' );

  if nargin ~= 1			% Check number of input arguments.
  
	error();				% get error if function is called with other than
  						% one input parameter
  end

  if nargout ~= 2		% Check number of output arguments.
  
	error();				% get error if function is called with other than
  						% two output parameters
  end

  fid = open_file( filename );	% calling internal function (see below) to open the file
  
  % read the leading commentary of the fsc2 file line by line
  % and extract the necessary parameters:
  
  read = '%';					% variable 'read' set to '%' to initially
  								% match the while loop condition
  								
  while index (read, '%' ) == 1	% while read line starts with '%'
  
    read = fgetl ( fid );			% linewise read of file

	parameter = read_parameter_from_fsc2 ( read, 'Start field' );
								% calling internal function (see below) to check whether
								% the desired parameter stands in the actual line
								
	if isnumeric(parameter) ~= 0	% the function "read_parameter_from_fsc2" returns "NaN" if
								% the parameter is not found in the actual line
								% Therefore check whether "parameter" is numeric
	  start_field = parameter		% and in this case set the variable
	  
	end

	% repeat the above described for the other parameters

	parameter = read_parameter_from_fsc2 ( read, 'End field' );
	if isnumeric(parameter) ~= 0
	  end_field = parameter
	end

	parameter = read_parameter_from_fsc2 ( read, 'Field step width' );
	if isnumeric(parameter) ~= 0
	  field_step_width = parameter
	end

	parameter = read_parameter_from_fsc2 ( read, 'Number of points' );
	if isnumeric(parameter) ~= 0
	  no_points = parameter
	end

	parameter = read_parameter_from_fsc2 ( read, 'Trigger position' );
	if isnumeric(parameter) ~= 0
	  trigger_pos = parameter
	end
	
  end								% end of while loop
  
  close_file( fid );					% calling internal function (see below) to close the file
  
  
  % calculations for the dimension of the 2D-matrix for finally storing the data
  
  field_width = (end_field - start_field) / field_step_width
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
  
  matrix = zeros (field_width, no_points);
  									% for faster computing of octave initialize empty matrix
  									% with the above calculated final dimensions
  
  % now read the actual data
  
  raw_data = load ( filename );		% read fsc2 data file (automatically ignore comments)


  % fill the previously initialized empty matrix with the data read from the file

  for i = 1:(field_width+1)
    matrix (i,:) = raw_data(1+((i-1)*no_points):i*no_points)';
  end


  % return the data as matrix

  if hightolow == 1					% if measured from higher to lower fields
    data = flipud ( matrix );			% reverse rows of the matrix containing the data
  else
	data = matrix;					% otherwise return the data as recorded by fsc2
  end

  % end of main function
	
	
%******


%##############################################################
% SUBFUNCTIONS


%****if* read_fsc2_data/open_file

function fid = open_file ( filename )

  % Open file FILENAME for read and checks whether file is openend
  % if not, an error message is printed and further evaluation of the script
  % is aborted
 
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
	
function status = close_file ( fid )
	
  % close file
	
  status = fclose ( fid );

  % end subfunction close_file
  
%******

%****if* read_fsc2_data/read_parameter_from_fsc2
  
function value = read_parameter_from_fsc2 ( string, description )

  % This function checks whether the string STRING contains the substring
  % DESCRIPTION and in this case returns the value VALUE that is printed at
  % a defined position behind the substring DESCRIPTION in the leading commentary
  % of the fsc2 data file.

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
        							
      end						% end if
      
      value = str2num( res );		% the value (string) is converted to a number
      
    else							% If the string DESCRIPTION is not found in the string STRING
    								% or if DESCRIPTION starts not at position 3 of STRING
    
      value = 'NaN';				% set the return variable "value" to a defined nonnumeric value
      
    end							% end if

    % end subfunction read_parameter_from_fsc2
    
%******
