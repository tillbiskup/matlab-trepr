% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author: Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer: Till Biskup <till.biskup@physik.fu-berlin.de>
% Created: 2005/09/28
% Version: $Revision$
% Keywords: transient EPR, fsc2
% 
%READ_FSC2_DATA reads parameters and data from fsc2 data file
%
%	usage: DATA = read_fsc2_data ( FILENAME )
%
%	This function opens the file FILENAME, looks for some
%	parameters necessary for the further data analysis that
%	are written in the leading commentary and returns a matrix
%	DATA of the raw data.

function data = read_fsc2_data (filename)

  fid = open_file( filename );
  
  % read the leading commentary of the fsc2 file
  
  read = '%';					% variable 'read' set to '%' to match the while loop condition
  while index (read, '%' ) == 1	% while read line starts with '%'
    read = fgetl ( fid );			% linewise read of file

	parameter = read_parameter_from_fsc2 ( read, 'Start field' );
	if isnumeric(parameter) ~= 0
	  start_field = parameter
	end

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
  end
  
  close_file( fid );
  
  field_width = (end_field - start_field) / field_step_width
  
  matrix = zeros (field_width, no_points);
  
  raw_data = load ( filename );		% read fsc2 data file (automatically ignore comments)

  for i = 1:(field_width+1)
    matrix (i,:) = raw_data(1+((i-1)*no_points):i*no_points)';
  end

  data = matrix;

	
%##############################################################
% SUBFUNCTIONS


function fid = open_file ( filename )

  % Open fsc2 file with data
 
  fid = 0;
  while fid < 1
  	[fid,message] = fopen ( filename, 'r' );
  	if fid == -1
  	  fprintf( message );
  	end
  end


	
function status = close_file ( fid )
	
  % close file
	
  status = fclose ( fid );

  
  
function value = read_parameter_from_fsc2 ( string, description )

    if index ( string, description ) == 3  
      res = substr ( string, 23 );
      contains_spaces = findstr ( res, ' ' );
      if length(contains_spaces) > 1 && index (res, ' ') > 0
        res = substr ( res, 1, contains_spaces(2)-2 );
      end
      value = str2num( res );
    else
      value = 'NaN';
    end
