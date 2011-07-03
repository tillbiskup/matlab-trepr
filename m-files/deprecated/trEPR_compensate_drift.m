% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/trEPR_compensate_drift.m
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
%	$Revision: 931 $
% MODIFICATION DATE
%	$Date: 2009-02-19 19:56:07 +0000 (Do, 19 Feb 2009) $
% DERIVED FROM
%	script_drift_show_compensated.m
%	script_drift.m
% KEYWORDS
%	transient EPR, drift, compensate drift
%
% SYNOPSIS
%	data = trEPR_compensate_drift ( data, field_params, time_params, t, B0_halfwidth )
%
% DESCRIPTION
%	trEPR_compensate_drift lets the user choose initially between two different
%	drift evaluation methods (show drift and fit polynom and show spectrum at
%	maximum amplitude) and provides the possibility to choose a polynomial fit
%	of zero to ninth order.
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
%	t
%		scalar containing the column index of DATA where the maximum of the whole
%		matrix (and thus the signal maximum of the B_0 spectrum) is located at.
%
%		This value can be evaluated with the function trEPR_find_maximum_amplitude.
%
%	B0_halfwidth (OPTIONAL)
%		Parameter for the B0_spectrum routine that displays a B_0 spectrum averaged
%		over (B0_halfwidth * 2 + 1) B_0 slices.
%
%		If not set, B0_halfwidth will be set to 2, meaning that the B_0 spectra are
%		averaged over 5 B_0 slices
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the drift compensated data
%
% DEPENDS ON
%	This function depends on the following other functions of the toolbox:
%	* drift_evaluation
%	* drift_compensation
%	* drift_compensation_along_t
%
% EXAMPLE
%	To compensate the drift for the recorded measurement DATA with the field params
%	FP and the time params TP and an index for the maximum amplitude of the B_0
%	spectrum of 100 typein
%
%		data = trEPR_compensate_drift ( data, fp, tp, 100 )
%
% COMPATIBILITY
% 	This routine is fully compatible and works perfect together with GNU OCTAVE
%
% SOURCE

function [ data ] = trEPR_compensate_drift ( data, field_params, time_params, t, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id: trEPR_compensate_drift.m 931 2009-02-19 19:56:07Z till $\n%% ' );

	% check for right number of input and output parameters

	if ( (nargin < 4) || (nargin > 5) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help tEPR_compensate_drift" to get help.',nargin);
			% get error if function is called with other than
			% four input parameters
	end

	if nargout ~= 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help tEPR_compensate_drift" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% FIELD_PARAMS

	elseif ~isnumeric(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif ~isvector(field_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	elseif length(field_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','field_params');
			% get error if function is called with the wrong format of the
			% input parameter 'field_params'

	% TIME_PARAMS

	elseif ~isnumeric(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif ~isvector(time_params)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	elseif length(time_params) ~= 3

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','time_params');
			% get error if function is called with the wrong format of the
			% input parameter 'time_params'

	% T

	elseif ( ~isnumeric(t) || ~isscalar(t) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help tEPR_compensate_drift" to get help.','t');
			% get error if function is called with the wrong format of the
			% input parameter 't'
	
	end
	
	if ( nargin == 7 )
	
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

	if ( exist('drift_evaluation.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'drift_evaluation');


	elseif ( exist('drift_compensation.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'drift_compensation.m');


	elseif ( exist('drift_compensation_along_t.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'drift_compensation_along_t.m');

	end



	drift_display = menu ( 'DRIFT COMPENSATION: Which display mode should be used?', 'Show drift and fit curve', 'Show B_0 spectrum at signal maximum' );

	if ( drift_display == 1)

		fprintf('\tShow drift and fit curve chosen\n');
		
		% call internal function compensate_drift
  
		data = compensate_drift ( data, field_params, time_params, t );

	else

		fprintf('\tShow B_0 spectrum at signal maximum chosen\n');
		
		% call internal function compensate_drift_show_compensated

		data = compensate_drift_show_compensated ( data, field_params, time_params, t, B0_halfwidth );

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

	[drift,pv0,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (data,20);


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

		method_drift_comp = menu ( 'Choose an option for drift compensation', '0th oder', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Compensate with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use


		if ( method_drift_comp == 1 )

			plot(x,drift,x,pv0);

		elseif ( method_drift_comp == 2 )

			plot(x,drift,x,pv1);

		elseif ( method_drift_comp == 3 )

			plot(x,drift,x,pv2);

		elseif ( method_drift_comp == 4 )

			plot(x,drift,'-',x,pv3,'-');

		elseif ( method_drift_comp == 5 )

			plot(x,drift,'-',x,pv4,'-');

		elseif ( method_drift_comp == 6 )

			plot(x,drift,'-',x,pv5,'-');

		elseif ( method_drift_comp == 7 )

			plot(x,drift,'-',x,pv6,'-');

		elseif ( method_drift_comp == 8 )

			plot(x,drift,'-',x,pv7,'-');

		elseif ( method_drift_comp == 9 )

			exit_condition = 1;

		elseif ( method_drift_comp == 10 )

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

	fprintf('\n%% Compensate B_0 drift along the t axis...\n%% ')

	if ( method_drift_comp == 1 )
						% if the user chose linear fit

		fprintf('\n%% Linear drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv0);
		data = drift_compensation(data, pv0, 10);

	elseif ( method_drift_comp == 2 )
						% if the user chose quadratic fit

		fprintf('\n%% Quadratic drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv1);
		data = drift_compensation(data, pv1, 10);

	elseif ( method_drift_comp == 3 )
						% if the user chose quadratic fit

		fprintf('\n%% Quadratic drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv2);
		data = drift_compensation(data, pv2, 10);

	elseif ( method_drift_comp == 4 )
						% if the user chose cubic fit

		fprintf('\n%% Cubic drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv3);
		data = drift_compensation(data, pv3, 10);

	elseif ( method_drift_comp == 5 )
						% if the user chose 4th order fit

		fprintf('\n%% 4th order drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv4);
		data = drift_compensation(data, pv4, 10);

	elseif ( method_drift_comp == 6 )
						% if the user chose 5th order fit

		fprintf('\n%% 5th order drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv5);
		data = drift_compensation(data, pv5, 10);

	elseif ( method_drift_comp == 7 )
						% if the user chose 6th order fit

		fprintf('\n%% 6th order drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv6);
		data = drift_compensation(data, pv6, 10);

	elseif ( method_drift_comp == 8 )
						% if the user chose 7th order fit

		fprintf('\n%% 7th order drift compensation method chosen...\n%% ');

%		data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv7);
		data = drift_compensation(data, pv7, 10);

	else						% if user chose to do no fit at all

		fprintf('\n%% No drift compensation method chosen...\n%% ');

		data = data;
  						% set data to data without further computation

	end


%******


%****if* trEPR_compensate_drift/compensate_drift_show_compensated
%
% SYNOPSIS
%	data = compensate_drift_show_compensated ( data, field_params, time_params, t, B0_halfwidth )
%
% DESCRIPTION
%
% SOURCE

function data = compensate_drift_show_compensated ( data, field_params, time_params, t, B0_halfwidth )

	field_boundaries = [ field_params(1) field_params(2) ];
	trigger_pos = time_params(3);

	% Evaluate drift and possible fits

	[drift,pv0,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (data,20);

	[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
	x = [1:1:drift_cols];		% create x-axis values 

	% Plot B_0 spectrum at signal maximum in t
   
	[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
	x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
	plot(x,spectrum,'-',x,zeros(1,length(x)));

	title('Drift and polynomic fit');

	exit_condition = 0;

	while ( exit_condition == 0 )

		method_drift_comp = menu ( 'Choose an option for drift compensation', '0th oder', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Continue with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use

  
		if ( method_drift_comp == 1 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv0);
    				data = drift_compensation(data, pv0, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));
    
				chosen_method = '0th order';

		elseif ( method_drift_comp == 2 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv1);
    				data = drift_compensation(data, pv1, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '1st order';

		elseif ( method_drift_comp == 3 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv2);
    				data = drift_compensation(data, pv2, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '2nd order';

		elseif ( method_drift_comp == 4 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv3);
    				data = drift_compensation(data, pv3, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '3rd order';

		elseif ( method_drift_comp == 5 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv4);
    				data = drift_compensation(data, pv4, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '4th order';

		elseif ( method_drift_comp == 6 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv5);
    				data = drift_compensation(data, pv5, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '5th order';

		elseif ( method_drift_comp == 7 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv6);
    				data = drift_compensation(data, pv6, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '6th order';

		elseif ( method_drift_comp == 8 )

%				data = drift_compensation_along_t(data, trigger_pos, 100, 10, pv7);
    				data = drift_compensation(data, pv7, 10);
    
				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = '7th order';

		elseif ( method_drift_comp == 9 )

				data = data;

				[ spectrum, max_ind ] = B0_spectrum ( data, B0_halfwidth, t );
				x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
				plot(x,spectrum,x,zeros(1,length(x)));

				chosen_method = 'none';

		elseif ( method_drift_comp == 10 )

			if ( exist('chosen_method') == 0 )
						% in the case the user hits 'Continue...' before choosing an option...

				chosen_method = 'none';
	
			end

			exit_condition = 1;

		end
  
	end

	fprintf( '\n%% Eventually chosen drift compensation method: %s\n%% ', chosen_method );


%******
