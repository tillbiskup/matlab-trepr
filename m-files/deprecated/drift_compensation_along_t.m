% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/drift_compensation_along_t.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/11
% VERSION
%	$Revision: 291 $
% MODIFICATION DATE
%	$Date: 2006-07-28 16:06:13 +0100 (Fr, 28 Jul 2006) $
% KEYWORDS
%	transient EPR, fsc2, drift compensation in 2D
%
% SYNOPSIS
%	DATA = drift_compensation_along_t ( data, trigger_pos, stable_t, no_ts, drift )
%
% DESCRIPTION
%	This function compensates for large-scale drifts across the whole spectrum in
%	both dimensions, B_0 field range and time range, at the same time.
%
%	Generally spoken the function runs column by column (along the time axis) along
%	the matrix DATA containing the measured (and somehow compensated) data and
%	subtracts at each step a curve that is computed as a product of the drift along
%	the B_0 field axis and the weight along the time axis:
%
%		data(i,:) = data(i,:) - (drift *	weights(i))
%
%	where drift is the drift along the B_0 axis evaluated before (e.g. with the
%	function 'drift_evaluation) and the weights along the time axis that have to be
%	evaluated from off-resonant time slices of the recorded dataset.
%
%	(a) drift compensation along the time axis
%
%	To perform this task one has to take into account that the off-resonance signal
%	is not flat but raises directly after the laserflash and normally rests at this
%	higher level for the whole recording time:
%
%		         ___________________________________________________
%		        /
%		       /
%		______/.....................................................
%
%		      ^
%		    laser flash (at the same time trigger pulse for the scope)
%
%		The dotted line (...) represents the zero signal level the signal would
%		rest on if there were no laser flash.
%
%	This effect can be explained by the heating due to the energy the laser applies
%	to the resonator and consequently a slight de-tuning of the otherwise critically
%	coupled resonator.
%
%	The "trick" is now to take a Nx1 vector of the same length as a time slice
%	containing weights that resemble the values of an off-resonant time slice.
%
%	These weights are clearly zero for all time before the trigger pulse and one
%	beginning at the time where the off-resonance signal raised its stable maximum.
%	Normally they will rise linearly after the trigger pulse until they reach the
%	stable maximum position, but as the weights are provided as a vector to the
%	function every kind of weights is possible.
%
%	(b) drift compensation along the B_0 field axis
%
%	The second dimension is often affected by some kind of drift as well, either by
%	a real drift or e.g. an underlying triplett spectrum.
%
%	To account therefor the DRIFT vector provided as third input parameter is
%	subtracted	(after being multiplied with the weight from the compensation
%	along the time axis) from each B_0 slice.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured (and therefore biased) data
%
%	trigger_pos
%		scalar containing the position of the trigger pulse
%
%		Normally this parameter is returned by the function trEPR_read_fsc2_file.
%
%	stable_t
%		scalar containing the position along the time axis from where on the signal
%		is stable over time.
%
%	no_ts
%		scalar containing the number of time slices at the lower end of the
%		B_0 field that are used to compute the drift compensation.
%
%	drift
%		1xN vector containing the drift of the spectrum along the B_0 field axis
%		as evaluated by the function drift_evaluation
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the drift-compensated data
%
% EXAMPLE
%	Suppose we have a measured record DATA, the DRIFT evaluated from the record via
%	the function drift_evaluation, the trigger position is at 50, the position in
%	the time slice for stable signal is at 200 and we want to average over the first
%	10 off-resonance time slices:
%
%		data = drift_compensation_along_t ( data, 50, 200, 10, drift )
%
% SOURCE

function data = drift_compensation_along_t ( data, trigger_pos, stable_t, no_ts, drift )

	fprintf ( '\nFUNCTION CALL: $Id: drift_compensation_along_t.m 291 2006-07-28 15:06:13Z web8 $\n' );

	% check for right number of input and output parameters

	if (nargin ~= 5)
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help drift_compensation_along_t" to get help.',nargin);
			% get error if function is called with other than
			% five input parameters
	end

	if nargout ~= 1		% Check number of output arguments.
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help drift_compensation_along_t" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation_along_t" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% TRIGGER_POS

	elseif ( ~isnumeric(trigger_pos) || ~isscalar(trigger_pos) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation_along_t" to get help.','trigger_pos');
			% get error if function is called with the wrong format of the
			% input parameter 'trigger_pos'

	% STABLE_T

	elseif ( ~isnumeric(stable_t) || ~isscalar(stable_t) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation_along_t" to get help.','stable_t');
			% get error if function is called with the wrong format of the
			% input parameter 'stable_t'

	% NO_TS

	elseif ( ~isnumeric(no_ts) || ~isscalar(no_ts) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation_along_t" to get help.','no_ts');
			% get error if function is called with the wrong format of the
			% input parameter 'no_ts'

	% DRIFT

	elseif ( ~isnumeric(drift) || ~isvector(drift) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation_along_t" to get help.','drift');
			% get error if function is called with the wrong format of the
			% input parameter 'drift'

	end


	% First step: Compute mean values for lower end of B_0 field
	
	ts_mean = mean ( data ( [1:no_ts], : ) );
							% average over the first 'no_ts' time slices


	% Second step: determine t1
	
	[ ts_mean_rows, ts_mean_cols ] = size ( ts_mean );
							% determine size of ts_mean
	
	upper_t_mean = mean ( ts_mean( [ stable_t : ts_mean_cols ] ) );
							% compute (arithmetic) mean of t for t >> t_1
	
	upper_t_std = std ( ts_mean( [ stable_t : ts_mean_cols ] ) );
							% compute standard deviation of t for t >> t_1
							
	threshold = upper_t_mean - upper_t_std;
							% compute threshold for determining t_1
	
	i = trigger_pos;		% set start point of while loop to trigger position
	
	if ts_mean(i) < threshold
		% if starting condition of the while loop matches
		% (it doesn't match if the difference in the signal value
		% of the off-resonance noise before and after the trigger pulse
		% is very small)
	 
		while ( ts_mean(i) < threshold )
			% while value of ts_mean for given position i is smaller than
			% the above computed threshold
	
			t_1 = i;				% set t_1 = i
		
			i = i+1;				% increment i
	
		end		% end of while loop
	
	else			% in case the while loop condition doesn't match
	
		t_1 = i;
			% set t_1 to the trigger_pos value
			% the addition of 1 is necessary not to produce a division by zero
			% when calculating the slope_of_weights below
								
		fprintf('\n%% INFO: There is no difference in the off-resonance signal before and after the trigger.\n%% ');

	end
	
	
	% set slope of weights
	
	if (t_1 > trigger_pos)
	
		slope_of_weights = 1 / ( t_1 - trigger_pos );
		
	else					% this is only the case if t_1 equals trigger_pos
	
		slope_of_weights = 1;
	
	end
	
	
	% create vector with weights

	drift_weights = [ (zeros (1,trigger_pos-1)), ([ 0 : slope_of_weights : 1 ]), (ones (1,ts_mean_cols-t_1)) ];
		% for 0 <= t <= trigger_pos-1		weights = 0
		% for trigger_pos <= t <= t_1 	0 <= weights <= 1
		% increase stepwise as determined by slope_of_weights
		% for t_1 < t < t_max				weights = 1

	% drift compensation

	for i= 1 : ts_mean_cols
		% for all time points

		data (:, i) = data ( :, i ) - ( drift_weights(i) * drift' ) ;
			% subtract values of drift weighted by drift_weights
			% from the input data
	
	end 		% end of for loop

%******
