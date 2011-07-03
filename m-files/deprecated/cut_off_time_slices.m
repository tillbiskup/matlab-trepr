% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/cut_off_time_slices.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/25
% VERSION
%	$Revision: 236 $
% MODIFICATION DATE
%	$Date: 2006-05-31 18:31:16 +0100 (Mi, 31 Mai 2006) $
% KEYWORDS
%	transient EPR, fsc2, cut spectrum
%
% SYNOPSIS
%	[ DATA, FIELD_PARAMS ] = cut_off_time_slices ( data, no_first_time_slices, no_last_time_slices, field_params )
%
% DESCRIPTION
%	This function cuts off time slices from the start and the end of a given matrix 
%	INPUT_DATA and returns the matrix DATA with cut off start and end.
%
%	This is useful for large drifts that can easily be compensated by cutting of the first
%	and/or the last time slices.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	no_first_time_slices
%		
%
%	no_last_time_slices
%		
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

% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the cut data
%
%	field_params
%		a 3x1 vector containing the recalculated "field parameters".
%
%		For a more complete description of these parameters please refer to the
%		description of the input parameters
%
% EXAMPLE
%	Suppose we want to cut off the first 20 time slices of the spectrum DATA:
%
%		[ data, fp ] = cut_off_time_slices ( data, 20, 0, fp)
%
%	Otherwise if we want to cut off the last 15 time slices of the spectrum DATA:
%
%		[ data, fp ] = cut_off_time_slices ( data, 0, 15, fp)
%
% SOURCE

function [ data, field_params ] = cut_off_time_slices ( data, no_first_time_slices, no_last_time_slices, field_params )

	fprintf ( '\nFUNCTION CALL: $Id: cut_off_time_slices.m 236 2006-05-31 17:31:16Z web8 $\n' );

	% check for right number of input and output parameters

	if nargin ~= 4
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help cut_off_time_slices" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
	end

	if nargout ~= 2
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help cut_off_time_slices" to get help.',nargout);
			% get error if function is called with other than
			% two output parameters
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix1'

	% NO_FIRST_TIME_SLICES

	elseif ( ~isnumeric(no_first_time_slices) || ~isscalar(no_first_time_slices) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','no_first_time_slices');
			% get error if function is called with the wrong format of the
			% input parameter 'no_first_time_slices'

	% NO_LAST_TIME_SLICES

	elseif ( ~isnumeric(no_last_time_slices) || ~isscalar(no_last_time_slices) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','no_last_time_slices');
			% get error if function is called with the wrong format of the
			% input parameter 'no_last_time_slices'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help cut_off_time_slices" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'
	
	[ ts, bs ] = size(data);
							% determine size of input matrix
	
	data = data ( (1+no_first_time_slices) : (ts-no_last_time_slices) , : );
							% write data as cut off input matrix

	if ( field_params(2) > field_params(1) )
	
		field_params = [ ( field_params(1) + (no_first_time_slices*(abs(field_params(3)))) ) ( field_params(2) - (no_last_time_slices*(abs(field_params(3)))) ) field_params(3) ];
							% set new field parameters
							% cause the start and end of the B_0 field has (possibly) changed
							% due to the cut off of time slices
	
	else 
	
		field_params = [ ( field_params(1) - (no_last_time_slices*(abs(field_params(3)))) ) ( field_params(2) + (no_first_time_slices*(abs(field_params(3)))) ) field_params(3) ];
							% set new field parameters
							% cause the start and end of the B_0 field has (possibly) changed
							% due to the cut off of time slices

	end
	
%******
