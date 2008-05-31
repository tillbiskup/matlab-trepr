% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/adjust_matrix_size.m
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
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, accumulation, adjust matrix sizes
%
% SYNOPSIS
%	[ new_matrix1, new_matrix2, new_field_params1, new_field_params2 ] = adjust_matrix_size ( matrix1, field_params1, time_params1, matrix2, field_params2, time_params2 )
%
% DESCRIPTION
%	This function takes two matrices, evaluates the sizes and parameters of them and
%	adjusts them to give two new matrices of the same size and same parameters.
%	Most of the time one of both matrices will be the same as the input matrix.
%
% INPUT PARAMETERS
%	matrix1
%		NxM or 1xM matrix containing the first set of measured data
%
%	field_params1
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
%	time_params1
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
%	matrix2
%		same as matrix2 for second set of measured data
%
%	field_params2
%		same as field_params1 for second set of measured data
%
%	time_params2
%		same as time_params1 for second set of measured data
%
% OUTPUT PARAMETERS
%	new_matrix1
%		NxM matrix containing the first set of measured data
%		with dimensions adjusted to the second matrix, matrix2
%
%	new_field_params1
%		a 3x1 vector containing of three values, the "field parameters"
%		after the dimensions of matrix1 were adjusted to matrix2
%
%	new_matrix2
%		NxM matrix containing the first set of measured data
%		with dimensions adjusted to the second matrix, matrix2
%
%	new_field_params2
%		a 3x1 vector containing of three values, the "field parameters"
%		after the dimensions of matrix1 were adjusted to matrix2
%
% EXAMPLE
%	[matrix1, matrix2, fp1, fp2] = adjust_matrix_size (matrix1, fp1, tp1, matrix2, fp2, tp2)
%
% TODO
%	Adjust not only according to the field parameters but as well according to the
%	time domain thus that if two matrices are accumulated that have been recorded
%	with different resolution in the time range that will lead to somehow reasonable
%	results. In that case a warning should be printed out.
%
% SOURCE

function [ new_matrix1, new_matrix2, new_field_params1, new_field_params2 ] = adjust_matrix_size ( matrix1, field_params1, time_params1, matrix2, field_params2, time_params2 )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n%% ' );

	% check for the right number of input and output parameters

	if ( nargin ~= 6 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help adjust_matrix_size" to get help.',nargin);

	end

	if ( nargout ~= 4 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help adjust_matrix_size" to get help.',nargout);

	end

	% check for correct format of the input parameters
	
	% MATRIX1
	
	if ( ~isnumeric(matrix1) || isscalar(matrix1) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','matrix1');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix1'

	% FIELD_PARAMS1

	elseif ~isnumeric(field_params1)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params1)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params1) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS1

	elseif ~isnumeric(time_params1)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params1)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params1) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params1');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
	
	% MATRIX2
	
	elseif ( ~isnumeric(matrix2) || isscalar(matrix2) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','matrix2');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix2'

	% FIELD_PARAMS2

	elseif ~isnumeric(field_params2)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params2'

	elseif ~isvector(field_params2)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params2'

	elseif length(field_params2) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','field_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params2'

	% TIME_PARAMS2

	elseif ~isnumeric(time_params2) 

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params2'

	elseif ~isvector(time_params2)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params2'

	elseif length(time_params2) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help adjust_matrix_size" to get help.','time_params2');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params2'

	end
	
	
	global DEBUGGING;

	% DEBUGGING OUTPUT
	if ( DEBUGGING )
		fprintf('\n%% DEBUGGING OUTPUT:\n%% ');
		fprintf('\tDimensions and field parameters of matrices before adjustment:\n%% ');
		fprintf('\tSize of matrix1:\t%i %i\n%% ', size(matrix1));
		fprintf('\tSize of matrix2:\t%i %i\n%% ', size(matrix2));
		fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n%% ', field_params1);
		fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n%% ', field_params2);
	end;
	
	if ( (abs(field_params1(2)-field_params1(1)) == abs(field_params2(2)-field_params2(1))) & (abs(field_params1(3)) == abs(field_params2(3))) & (time_params1 == time_params2) )
							% in case that field width and field_step_width and the time_params
							% of both spectra are equal
							% the absolute values are necessary cause the spectra are recorded
							% along increasing and decreasing B_0 field alternatively
	new_matrix1 = matrix1;
	new_matrix2 = matrix2;
							% just set the output matrices equal to the input matrices
	new_field_params1 = field_params1;
	new_field_params2 = field_params2;
							% just set the field params equal to the params of one of the input matrices
	
	else						% if matrices differ in some way
								% do the real work...

		field_width1 = abs( field_params1(2) - field_params1(1) );
		field_width2 = abs( field_params2(2) - field_params2(1) );
								% calculate field width from field_params
							% the absolute values are necessary cause the spectra are recorded
							% along increasing and decreasing B_0 field alternatively

	field_boundaries1 = [ field_params1(1) field_params1(2) ];
	field_boundaries2 = [ field_params2(1) field_params2(2) ];
	
	if ( ( min(field_boundaries1) > max(field_boundaries2) ) | ( min(field_boundaries2) > max(field_boundaries1 ) ) )
							% if field boundaries have no overlapping region
	
		fprintf( '\n%% PROBLEM: Matrices have no overlapping field boundaries!\n%%          No way to accumulate...\n%% ' );
		
		error ( '' );
		
	elseif ( min(field_boundaries1) < min(field_boundaries2) )
							% if field boundaries do overlap
							% and matrix1 starts at lower B_0 field than matrix2
	
		if ( abs(field_params1(3)) < abs(field_params2(3)) )
								% for field_step_width of matrix2 be bigger than that of matrix1
								
			fprintf( '\n%% PROBLEM: Field step width of second matrix is bigger than that of the first matrix...\n%% ' );
			
			error ( '' );			% for the moment get an error and abort further execution
								
		elseif( abs(field_params1(3)) > abs(field_params2(3)) )
								% for field_step_width of matrix2 be smaller than that of matrix1

			fprintf( '\n%% PROBLEM: Field step width of first matrix is bigger than that of the second matrix...\n%% ' );
		
			error ();			% for the moment get an error and abort further execution
								
		else					% that is, if field_params1(3) equals field_params2(3)
								% for field_step_width be equal with both matrices
								
			lower_field_boundary = min( [ max(field_boundaries1) max(field_boundaries2) ] );
									% gives the lower upper field boundary of both matrices
	
%		if ( ( isvector(matrix1) == 0 ) && ( isvector(matrix2) == 0 ) ) 
	
			% if both matrices are not 1D
									
				for i = 1 : (( lower_field_boundary - min(field_boundaries2))/abs(field_params2(3))+1)
								% for i running from 1 to the upper boundary of the matrix
								% with lower upper field boundary
			
				new_matrix1 ( i , : ) = matrix1 ( i+((min(field_boundaries2)-min(field_boundaries1))/abs(field_params1(3))) , : );
				
				new_matrix2 ( i , : ) = matrix2 ( i , : );
			
				end					% end of filling new matrices

		if ( field_params1(3) > 0)
							% if spectrum1 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params1 = [ (field_params1(1)+(min(field_boundaries2)-min(field_boundaries1))) lower_field_boundary field_params1(3) ];
			
		else
							% if spectrum1 recorded from higher to lower B_0 field

			new_field_params1 = [ lower_field_boundary (field_params1(2)+(min(field_boundaries2)-min(field_boundaries1))) field_params1(3) ];
		
		end;

		if ( field_params2(3) > 0)
							% if spectrum2 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params2 = [ field_params2(1) (field_params2(1)+(lower_field_boundary-min(field_boundaries2))) field_params2(3) ];
			
		else
							% if spectrum2 recorded from higher to lower B_0 field

			new_field_params2 = [ (field_params2(2)+(lower_field_boundary-min(field_boundaries2))) field_params2(2) field_params2(3) ];
		
		end;
			
		end

	elseif ( min(field_boundaries1) > min(field_boundaries2) )
							% if field boundaries do overlap
							% and matrix1 starts at higher B_0 field than matrix2

	
		if ( abs(field_params1(3)) < abs(field_params2(3)) )
								% for field_step_width of matrix2 be bigger than that of matrix1
								
			fprintf( '\n%% PROBLEM: Field step width of second matrix is bigger than that of the first matrix...\n%% ' );
			
			error ();			% for the moment get an error and abort further execution
								
		elseif( abs(field_params1(3)) > abs(field_params2(3)) )
								% for field_step_width of matrix2 be smaller than that of matrix1

			fprintf( '\n%% PROBLEM: Field step width of first matrix is bigger than that of the second matrix...\n%% ' );
		
			error ();			% for the moment get an error and abort further execution
								
		else					% that is, if field_params1(3) equals field_params2(3)
								% for field_step_width be equal with both matrices
								
			lower_field_boundary = min( [ max(field_boundaries1) max(field_boundaries2) ] );
									% gives the lower upper field boundary of both matrices
			
			for i = 1 : (( lower_field_boundary - min(field_boundaries1))/abs(field_params2(3))+1)
								% for i running from 1 to the upper boundary of the matrix
								% with lower upper field boundary
			
				new_matrix1 ( i , : ) = matrix1 ( i , : );
			
				new_matrix2 ( i , : ) = matrix2 ( i+((min(field_boundaries1)-min(field_boundaries2))/abs(field_params2(3))) , : );
				
			end					% end of filling new matrices

		if ( field_params1(3) > 0)
							% if spectrum1 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params1 = [ field_params1(1) (field_params1(1)+(lower_field_boundary-min(field_boundaries1))) field_params1(3) ];
			
		else
							% if spectrum1 recorded from higher to lower B_0 field

			new_field_params1 = [	(field_params1(2)+(lower_field_boundary-min(field_boundaries1))) field_params1(2) field_params1(3) ];
		
		end;

		if ( field_params2(3) > 0)
							% if spectrum2 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params2 = [ (field_params2(1)+(min(field_boundaries1)-min(field_boundaries2))) lower_field_boundary field_params2(3) ];
			
		else
							% if spectrum1 recorded from higher to lower B_0 field

			new_field_params2 = [ field_params2(1) (field_params2(1)-(lower_field_boundary-min(field_boundaries1))) field_params2(3) ];
		
		end;

		end
	
	else						% if field boundaries do overlap
							% and matrix1 starts at same B_0 field as matrix2

	
		if ( abs(field_params1(3)) < abs(field_params2(3)) )
								% for field_step_width of matrix2 be bigger than that of matrix1
								
			fprintf( '\n%% PROBLEM: Field step width of second matrix is bigger than that of the first matrix...\n%% ' );
			
			error ();			% for the moment get an error and abort further execution
								
		elseif( abs(field_params1(3)) > abs(field_params2(3)) )
								% for field_step_width of matrix2 be smaller than that of matrix1

			fprintf( '\n%% PROBLEM: Field step width of first matrix is bigger than that of the second matrix...\n%% ' );
		
			error ();			% for the moment get an error and abort further execution
								
		else					% that is, if field_params1(3) equals field_params2(3)
								% for field_step_width be equal with both matrices
								
			lower_field_boundary = min( [ max(field_boundaries1) max(field_boundaries2) ] );
									% gives the lower upper field boundary of both matrices
			
			for i = 1 : (( lower_field_boundary - min(field_boundaries1))/abs(field_params1(3))+1)
								% for i running from 1 to the upper boundary of the matrix
								% with lower upper field boundary
			
				new_matrix1 ( i , : ) = matrix1 ( i , : );
			
				new_matrix2 ( i , : ) = matrix2 ( i , : );
				
			end					% end of filling new matrices

		if ( field_params1(3) > 0)
							% if spectrum1 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params1 = [ field_params1(1) lower_field_boundary field_params1(3) ];
			
		else
							% if spectrum1 recorded from higher to lower B_0 field

			new_field_params1 = [ lower_field_boundary field_params1(2) field_params1(3) ];
		
		end;

		if ( field_params2(3) > 0)
							% if spectrum2 recorded from lower to higher B_0 field
							% field_params(3) is the field step width
							% and is > 0 for spectra recorded from low -> high B_0 field
							% and is < 0 for spectra recorded from high -> low B_0 field
							
			new_field_params2 = [ field_params2(1) lower_field_boundary field_params2(3) ];
			
		else
							% if spectrum2 recorded from higher to lower B_0 field

			new_field_params2 = [ lower_field_boundary field_params2(2) field_params2(3) ];
		
		end;
		
		end
	
	end						% end of comparison of field_width
	
	if ( time_params1 ~= time_params2 )
							% if the settings of the time axis are not equal
							% with both spectra
							
	
 		fprintf( '\n%% PROBLEM: Time parameters of both matrices are not equal...\n%% ' );
			
		error ();				% for the moment get an error and abort further execution
							
		% do some correction...
	
	end						% end of comparison of time_params
	
	end

	% DEBUGGING OUTPUT
	if ( DEBUGGING )
		fprintf('\n%% DEBUGGING OUTPUT:\n%% ');
		fprintf('\tDimensions and field parameters of matrices after adjustment:\n%%');
		fprintf('\tSize of matrix1:\t%i %i\n%% ', size(new_matrix1));
		fprintf('\tSize of matrix2:\t%i %i\n%% ', size(new_matrix2));
		fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n%% ', new_field_params1);
		fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n%% ', new_field_params2);
	end;

%******
