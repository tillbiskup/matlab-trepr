% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* user_routines/trEPR_compensate_drift.m
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
%	script_drift_show_compensated.m
%	script_drift.m
% KEYWORDS
%	MATLAB(R), GNU Octave, transient EPR, fsc2, read file
%
% SYNOPSIS
%	[ data ] = trEPR_compensate_drift ( data, field_params, time_params, t )
%
% DESCRIPTION
%	trEPR_compensate_drift lets the user choose initially between two different
%	drift evaluation methods (show drift and fit polynom and show spectrum at
%	maximum amplitude) and provides the possibility to choose a polynomial fit
%	of zero to ninth order.
%
% NOTE ACCORDING GNU OCTAVE
% 	This routine is fully compatible and works perfect together with GNU OCTAVE
%
% INPUT
%	data - matrix containing the 2D data
%	field_params - row vector containing the field parameters (start, stop, step width)
%	time_params - row vector containing the time parameters (length in points, trigger position, length in microseconds)
%	t - integer specifying the time position for the amplitude maximum of the spectrum
%
% OUTPUT
%	data - matrix containing the drift compensated 2D data
%
% SOURCE

function [ data ] = trEPR_compensate_drift ( data, field_params, time_params, t )


	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );

	% check for right number of input and output parameters

	if nargin ~= 4
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_compensate_drift" to get help.',nargin);
			% get error if function is called with other than
			% four input parameters
	end

	if nargout ~= 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_compensate_drift" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end


	drift_display = menu ( 'DRIFT COMPENSATION: Which display mode should be used?', 'Show drift and fit curve', 'Show B_0 spectrum at signal maximum' );

	if ( drift_display == 1)

		fprintf('\tShow drift and fit curve chosen\n');
  
		data = compensate_drift ( data, field_params, time_params, t );
		%%% script_drift;

	else

		fprintf('\tShow B_0 spectrum at signal maximum chosen\n');

		data = compensate_drift_show_compensated ( data, field_params, time_params, t );
		%%% script_drift_show_compensated;

	end

	
%******


%##############################################################
% SUBFUNCTIONS

%****if* trEPR_compensate_drift/compensate_drift
%
% SYNOPSIS
%	data = compensate_drift ( data, field_params, time_params, t )
%
% DESCRIPTION
%
% SOURCE

function data = compensate_drift ( data, field_params, time_params, t )

	field_boundaries = [ field_params(1) field_params(2) ];
	trigger_pos = time_params(3);

	% Evaluate drift and possible fits

	[drift,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (data,20);


	[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
	x = [1:1:drift_cols];		% create x-axis values 

	figure;					% Opens up a new plot window.

	plot(x,drift);
						% plot drift against x

	title('Drift and polynomic fit');

	exit_condition = 0;

	while ( exit_condition == 0 )

		method_drift_comp = menu ( 'Choose an option for drift compensation', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Compensate with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use


		if ( method_drift_comp == 1 )

			plot(x,drift,x,pv1);

		elseif ( method_drift_comp == 2 )

			plot(x,drift,x,pv2);

		elseif ( method_drift_comp == 3 )

			plot(x,drift,'-',x,pv3,'-');

		elseif ( method_drift_comp == 4 )

			plot(x,drift,'-',x,pv4,'-');

		elseif ( method_drift_comp == 5 )

			plot(x,drift,'-',x,pv5,'-');

		elseif ( method_drift_comp == 6 )

			plot(x,drift,'-',x,pv6,'-');

		elseif ( method_drift_comp == 7 )

			plot(x,drift,'-',x,pv7,'-');

		elseif ( method_drift_comp == 8 )

			exit_condition = 1;

		elseif ( method_drift_comp == 9 )

			exit_condition = 1;

			if exist ( 'old_method' )
    						% if user chose this option instead od "none"
    						% but hasn't chosen any other option the variable
    						% 'old_method' does not exist...

				method_drift_comp = old_method;
      
			end;
    
		end
  
		old_method = method_drift_comp;
  						% to save the previously chosen drift compensation
  						% method
  
	end

	% Compensate drift along the time axis

	fprintf('\nCompensate B_0 drift along the t axis...\n')

	if ( method_drift_comp == 1 )
						% if the user chose linear fit

		fprintf('\nLinear drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv1);

	elseif ( method_drift_comp == 2 )
						% if the user chose quadratic fit

		fprintf('\nQuadratic drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv2);

	elseif ( method_drift_comp == 3 )
						% if the user chose cubic fit

		fprintf('\nCubic drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv3);

	elseif ( method_drift_comp == 4 )
						% if the user chose 4th order fit

		fprintf('\n4th order drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv4);

	elseif ( method_drift_comp == 5 )
						% if the user chose 5th order fit

		fprintf('\n5th order drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv5);

	elseif ( method_drift_comp == 6 )
						% if the user chose 6th order fit

		fprintf('\n6th order drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv6);

	elseif ( method_drift_comp == 7 )
						% if the user chose 7th order fit

		fprintf('\n7th order drift compensation method chosen...\n');

		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv7);

	else						% if user chose to do no fit at all

		fprintf('\nNo drift compensation method chosen...\n');

		data = data;
  						% set data to data without further computation

	end


%******


%****if* trEPR_compensate_drift/compensate_drift_show_compensated
%
% SYNOPSIS
%	data = compensate_drift_show_compensated ( data, field_params, time_params, t )
%
% DESCRIPTION
%
% SOURCE

function data = compensate_drift_show_compensated ( data, field_params, time_params, t )

	field_boundaries = [ field_params(1) field_params(2) ];
	trigger_pos = time_params(3);

	% Evaluate drift and possible fits

	[drift,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (data,20);

	[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
	x = [1:1:drift_cols];		% create x-axis values 

	% Plot B_0 spectrum at signal maximum in t
   
	[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
	x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
	plot(x,spectrum,'-',x,zeros(1,length(x)));

	title('Drift and polynomic fit');

	exit_condition = 0;

	while ( exit_condition == 0 )

		method_drift_comp = menu ( 'Choose an option for drift compensation', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Continue with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use

  
		if ( method_drift_comp == 1 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv1);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));
    
				chosen_method = '1st order';

		elseif ( method_drift_comp == 2 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv2);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '2nd order';

		elseif ( method_drift_comp == 3 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv3);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '3rd order';

		elseif ( method_drift_comp == 4 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv4);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '4th order';

		elseif ( method_drift_comp == 5 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv5);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '5th order';

		elseif ( method_drift_comp == 6 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv6);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '6th order';

		elseif ( method_drift_comp == 7 )

				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv7);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '7th order';

		elseif ( method_drift_comp == 8 )

				data = data;

				[ spectrum, max_ind ] = B0_spectrum ( data, 2, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = 'none';

		elseif ( method_drift_comp == 9 )

			if ( exist('chosen_method') == 0 )
						% in the case the user hits 'Continue...' before choosing an option...

				chosen_method = 'none';
	
			end

			exit_condition = 1;

		end
  
	end

	fprintf( '\nEventually chosen drift compensation method: %s\n', chosen_method );


%******
