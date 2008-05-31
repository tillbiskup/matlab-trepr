% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/trEPR_find_maximum_amplitude.m
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
%	script_find_max_amplitude.m
% KEYWORDS
%	transient EPR, fsc2, B_0 spectrum, maximum
%
% SYNOPSIS
%	[ t, real_t ] = trEPR_find_maximum_amplitude ( data, field_params, time_params )
%
%	[ t, real_t ] = trEPR_find_maximum_amplitude ( data, field_params, time_params, B0_halfwidth )
%
% DESCRIPTION
%
%	Gives the user the possibility to control manually the position on the time axis
%	at which the signal amplitude of the B_0 spectrum is maximal. Therefore the user
%	can sweep through the whole spectrum along the time axis and/or type in directly
%	a value for t.
%
% NOTE ACCORDING GNU OCTAVE
% 	This script is fully compatible and works perfect together with GNU OCTAVE
%
% INPUT
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
% OUTPUT
%	t
%		scalar containing the column index of DATA where the maximum of the whole
%		matrix (and thus the signal maximum of the B_0 spectrum) is located at
%
%	real_t
%		same as T but as a real time (normally given in us, but depending on the
%		input parameter TIME_PARAMS)
%
% DEPENDS ON
%	DEBUGGING
%	program
%
%	B0_spectrum
%
% EXAMPLE
%	To evaluate the column index of DATA and the real time where the maximum of
%	the B_0 spectrum of the given dataset DATA lies just typein:
%
%		[ t, real_t ] = trEPR_find_maximum_amplitude ( data, fp, tp, 2 )
%
% SOURCE

function [ t, real_t ] = trEPR_find_maximum_amplitude ( data, field_params, time_params, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n%% ' );

	% check for right number of input and output parameters

	if ( (nargin < 3) || (nargin > 5) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargin);
			% get error if function is called with less than three or more than
			% four input parameters
	end

	if nargout ~= 2
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.',nargout);
			% get error if function is called with other than
			% two output parameters
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_find_maximum_amplitude" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'
	
	end
	
	if ( nargin == 4 )
	
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

	% check for the availability of the routines we depend on

	if ( exist('B0_spectrum.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'B0_spectrum');

	end

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
	
			fprintf('\n%% Sorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\n%% This function will behave as if it is called within MATLAB(TM)...\n%% Be aware: In the case that is not true you can run into problems!');
		
			program = 'Matlab';
			
			% set variable to default value
	
		end;
	
	end;

	% Plot B_0 spectrum and find signal maximum in t

	exit_find_max = 0;			% set while loop exit condition to default value;

	[ max_values, max_index ] = max( max( data ));
	[ min_values, min_index ] = min( min( data ));

	t = max_index;				% set time axis position to the t value of the maximum value of the script;

	% set x vector for plotting

	x = [ min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]) ];

	x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT

	while ( exit_find_max == 0 )

		spectrum = B0_spectrum ( data, B0_halfwidth, t );
  
		% DEBUGGING OUTPUT
		if ( DEBUGGING )
			fprintf('\n%% DEBUGGING OUTPUT:\n%% ');
			fprintf('\tfield_params:\t%4.2f %4.2f %2.2f\n%% ', field_params);
			fprintf('\tsize of x:\t\t%4.0f %4.0f\n%% ', size(x));
			fprintf('\tsize of spectrum:\t\t%4.0f %4.0f\n%% ', size(spectrum));
		end;

		if program == 'Octave'
			clg;
		else
			clf;
		end;

		hold on;

		real_t = time_params(3)/time_params(1) * ( t - time_params(2) );
			% calculate real time (in 1e-6 s) for the signal maximum
			% with time_params(1) = no_points, time_params(2) = trigger_pos
			% and time_params(3) = slice_length (in 1e-6 s)
  
		graph_title = sprintf( 'B_0 spectrum for evaluating the maximum signal amplitude depending on t with t=%i  (%5.2f us)', t, real_t );

		title(graph_title);
		xlabel('B / mT');
		ylabel('I');

		axis([ (min([field_params(1) field_params(2)])/10) (max([field_params(1) field_params(2)])/10) min_values max_values]);

		plot(x,spectrum',x,zeros(1,length(x)))
  
		hold off;
  
		freq_comp_option = menu ( 'What would you want to do?', '< t (1 step)', 't (1 step) >', '< t (10 step)', 't (10 step) >', 'Type in t value manually', 'Show 2D Spectrum', 'Proceed');
  
		if ( freq_comp_option == 1)
  
			t = t - 1;
  
		elseif ( freq_comp_option == 2)
  
			t = t + 1;
  
		elseif ( freq_comp_option == 3)
  
			t = t - 10;
  
		elseif ( freq_comp_option == 4)
  
			t = t + 10;
  
		elseif ( freq_comp_option == 5)

			t_manually = input ( '\nType in a t value manually: ', 's' );
			t = str2num (t_manually);
  
		elseif ( freq_comp_option == 6)
  
			fprintf('\n%% Plot 2D spectrum of offset-compensated data...\n%% ')

			figure;

			[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

			if program == 'Octave'			% if we're called by GNU Octave (as determined above)

				gsplot ( offset_comp_data' );			% make simple 3D plot of the raw data

			else								% otherwise we assume that we're called by MATLAB(R)

				mesh ( offset_comp_data );				% make simple 3D plot of the raw data

				title('2D plot of offset-compensated data');

			end
	
		elseif ( freq_comp_option == 7)
  
			exit_find_max = 1;
    					% set exit condition for while loop true
  
		end
  
	end;							% end of while loop

	fprintf('\n%% The user evaluated maximum signal amplitude is at t=%i\n%% that is %1.4f e-6 s after the trigger pulse.\n%% ', t, real_t)

%******
