% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/trEPR_cut_spectrum.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/04
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% DERIVED FROM
%	script_cut_off.m
% KEYWORDS
%	transient EPR, fsc2, cut spectrum
%
% SYNOPSIS
%	[ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params )
%
%	[ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params, B0_halfwidth )
%
%	[ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params, B0_halfwidth, t )
%
% DESCRIPTION
%
%	Allows the user to cut off interactively parts of the spectrum at its ends
%	and recalculates the correct field parameters.
%
%	At any time in the process the user can revert to the original
%	spectrum or just undo the last cut.
%
%	This should be performed after (manually) adjusting the signal maximum in time t
%	e.g. with the function 'trEPR_find_maximum_amplitude'.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
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
%	B0_halfwidth (OPTIONAL)
%		Parameter for the B0_spectrum routine that displays a B_0 spectrum averaged
%		over (B0_halfwidth * 2 + 1) B_0 slices.
%
%		If not set, B0_halfwidth will be set to 2, meaning that the B_0 spectra are
%		averaged over 5 B_0 slices
%
%	t (OPTIONAL)
%		scalar containing the column index of DATA where the maximum of the whole
%		matrix (and thus the signal maximum of the B_0 spectrum) is located at
%
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
% DEPENDS ON
%	PLOTTING3D
%	DEBUGGING
%	program
%
%	B0_spectrum
%	discriminate_matlab_octave
%	cut_off_time_slices
%
% EXAMPLE
%	[ data, fp ] = trEPR_cut_spectrum ( data, fp, tp )
%
%	[ data, fp ] = trEPR_cut_spectrum ( data, fp, tp, B0_halfwidth )
%
% SOURCE

function [ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n%% ' );

	% check for right number of input and output parameters

	if ( (nargin < 3) || (nargin > 5) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_cut_spectrum" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
	end

	if nargout ~= 2
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_cut_spectrum" to get help.',nargout);
			% get error if function is called with other than
			% two output parameters
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'matrix1'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_cut_spectrum" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
	
	end
	
	% OPTIONAL PARAMETERS
	
	% B0_HALFWIDTH
	
	if ( nargin > 3 )
	
		if ( ~isnumeric(varargin{1}) || ~isscalar(varargin{1}) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','B0_halfwidth');
				% get error if function is called with the wrong format of the
				% input parameter 'B0_halfwidth'
	
		else
		
			B0_halfwidth = varargin{1};
			
		end

	else
	
		B0_halfwidth = 2;
	
	end
	
	% T
	
	if ( nargin == 5 )
	
		if ( ~isnumeric(varargin{2}) || ~isscalar(varargin{2}) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','t');
				% get error if function is called with the wrong format of the
				% input parameter 't'
				
		else
		
			t = varargin{2};
		
		end

	end

	% check for the availability of the routines we depend on

	if ( exist('B0_spectrum.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'B0_spectrum');
	
	elseif ( exist('cut_off_time_slices.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'cut_off_time_slices');
	
	end

	% set some global variables

	global program;
	global DEBUGGING;
	global PLOTTING3D;
	
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
	
			fprintf('\n%% Sorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\n%% This function will behave as if it is called within MATLAB(TM)...\n%% Be aware: In the case that is not true you can run into problems!');
		
			program = 'Matlab';
			
			% set variable to default value
	
		end;
	
	end;

	% To be sure no signal is cut off
	% first print a B_0 spectrum

	if (exist('t') == 0)
		% if the parameter 't' is not provided as optional parameter
		% at the function call
	
		[ spectrum, max_index ] = B0_spectrum ( data, B0_halfwidth );
		
	else
		% in case we have an optional parameter 't'
	
		[ spectrum, max_index ] = B0_spectrum ( data, B0_halfwidth, t );
	
	end

	fprintf( '\n%% Index of maximum value: %i\n%% ', max_index );
 
	field_boundaries = [ field_params(1) field_params(2) ];

	x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];

	plot(x,spectrum','-',x,zeros(1,length(x)),'-');

	% save original data and original field_parameters

	original_data = data;
	original_field_params = field_params;

	% set variable to default value that matches while condition

	cut_off = 0;

	while (cut_off ~= 3)

		last_data = data;
		last_field_params = field_params;

		cut_off = menu ( 'Do you want to cut off time slices at beginning and/or end of the spectrum?', 'Yes, at the beginning', 'Yes, at the end', 'No', 'Undo last cut', 'Revert to original spectrum' );

		if ( cut_off == 1 )
						% if the user chose to cut off the beginning

			no_first_ts = input ( 'How many time slices do you want to cut of AT THE BEGINNING? ' );
    
			[ data, field_params ] = cut_off_time_slices ( data, no_first_ts, 0, field_params );

    
			% Plot raw data with cut time slices

			field_boundaries = [ field_params(1) field_params(2) ];

			[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

		elseif ( cut_off == 2 )
						% if the user chose to cut off the end

			no_last_ts = input ( 'How many time slices do you want to cut of AT THE END? ' );
    
			[ data, field_params ] = cut_off_time_slices ( data, 0, no_last_ts, field_params );
  
			% Plot raw data with cut time slices

			field_boundaries = [ field_params(1) field_params(2) ];

			[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

		elseif ( cut_off == 4 )
						% if the user chose to undo the last cut off
						
			data = last_data;
			field_params = last_field_params;

			field_boundaries = [ field_params(1) field_params(2) ];

			[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

		elseif ( cut_off == 5 )
						% if the user chose to revert to the original spectrum
						
			data = original_data;
			field_params = original_field_params;

			field_boundaries = [ field_params(1) field_params(2) ];

			[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

		end					% if condition

		if ( ( field_params == original_field_params ) )
  
			fprintf( '\n%% No cut off of the spectrum made.\n%% ' );
  
		end
  
		if ( PLOTTING3D )		% in the case the plot3d variable is set...
  
			if program == 'Octave'
  						% if we're called by GNU Octave (as determined above)

				gsplot ( data' );
	    					% make simple 3D plot of the raw data

			else					% otherwise we assume that we're called by MATLAB(R)

				mesh ( X', Y', data );
						% make simple 3D plot of the raw data

				title('Raw data');

			end
    
		end
  
	end						% end while (cut_off < 3) loop

%******
