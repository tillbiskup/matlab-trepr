% Copyright (C) 2005,2006 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/drift_compensation.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005,2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/07
% VERSION
%	$Revision: 291 $
% MODIFICATION DATE
%	$Date: 2006-07-28 16:06:13 +0100 (Fr, 28 Jul 2006) $
% KEYWORDS
%	transient EPR, fsc2, drift compensation in 2D
%
% SYNOPSIS
%	DATA = drift_compensation ( data, drift, lower_ts )
%	DATA = drift_compensation ( data, drift, lower_ts, upper_ts )
%
% DESCRIPTION
%	This function compensates for large-scale drifts across the whole spectrum in
%	both dimensions, B_0 field range and time range, at the same time.
%
%	Generally spoken the function runs row by row (along the B_0 field axis) along
%	the matrix DATA containing the measured (and somehow compensated) data and
%	subtracts at each step a curve that is computed as a product of the drift along
%	the B_0 field axis (as weight) and the off-resonant time slices at the begin and
%	end of the spectrum (summed up in the term 'weighted_drift'):
%
%		data(i,:) = data(i,:) - weighted_drift
%
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
%	One possibility to compensate therefor is to subtract the off-resonance "signal"
%	from each time slice while processing the whole spectrum along the B_0 field.
%
%	This off-resonance "signal" is taken from the first lower_ts time slices (and,
%	if provided, from the last upper_ts timeslices, otherwise from the last lower_ts
%	time slices) and averaged.
%
%	One has to take into account that even along the B_0 field axis there can be
%	a drift so that we have to compensate therefor as well.
%
%	(b) drift compensation along the B_0 field axis
%
%	The second dimension is often affected by some kind of drift as well, either by
%	a real drift or e.g. an underlying triplett spectrum.
%
%	To account therefor the DRIFT vector provided as second input parameter is
%	used to weight the averaged lower and upper off-resonance time slices that are
%	subtracted from each time slice.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured (and therefore biased) data
%
%	drift
%		1xN vector containing the drift of the spectrum along the B_0 field axis
%		as evaluated by the function drift_evaluation
%
%	lower_ts
%		scalar containing the number of time slices at the lower end of the
%		B_0 field that are used to compute the drift compensation.
%
%		If no fourth parameter is given this counts as well for the number of
%		time slices at the upper end of the B_0 field.
%
%	upper_ts (OPTIONAL)
%		scalar containing the number of time slices at the upper end of the
%		B_0 field that are used to compute the drift compensation.
%
%		If this parameter is not given the value of lower_ts is used for the 
%		number of time slices at the upper end of the B_0 field.
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the drift-compensated data
%
% EXAMPLE
%	Suppose we have a measured record DATA, the DRIFT evaluated from the record via
%	the function drift_evaluation, and we want to average over the first and last
%	10 off-resonance time slices:
%
%		data = drift_compensation ( data, drift, 10 )
%
%	In case of averaging over different numbers of time slices at the upper and 
%	lower end of the B_0 field axis of the spectrum use:
%
%		data = drift_compensation ( data, drift, 15, 7 )
%
% SOURCE

function data = drift_compensation ( data, drift, lower_ts, varargin )

	fprintf ( '\n%% FUNCTION CALL: $Id: drift_compensation.m 291 2006-07-28 15:06:13Z web8 $\n%% ' );

	% check for right number of input and output parameters

	if (nargin < 3) | (nargin > 4)
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help drift_compensation" to get help.',nargin);
			% get error if function is called with less than
			% three or more than four input parameters
	end

	if nargout ~= 1		% Check number of output arguments.
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help drift_compensation" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% DRIFT

	elseif ( ~isnumeric(drift) || ~isvector(drift) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation" to get help.','drift');
			% get error if function is called with the wrong format of the
			% input parameter 'drift'

	% LOWER_TS

	elseif ( ~isnumeric(lower_ts) || ~isscalar(lower_ts) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation" to get help.','lower_ts');
			% get error if function is called with the wrong format of the
			% input parameter 'lower_ts'

	end


	if nargin == 3
		% if number of input arguments is three
	
		upper_ts = lower_ts;	
			% set number of time slices at the upper end of the B_0 field
			% to the number of time slices at the lower end of the field
		
	else	
		% if number of input arguments is four
	
		upper_ts = varargin{1}(1);
			% set number of time slices at the upper end of the B_0 field
			% to the value given by the fourth parameter

		% check for correct format of the fourth input parameter

		if ( ~isnumeric(upper_ts) || ~isscalar(upper_ts) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_compensation" to get help.','upper_ts');
				% get error if function is called with the wrong format of the
				% input parameter 'upper_ts'

		end
	
	end


	% First step: Compute mean time slices for lower and upper end of B_0 field
	
	lower_ts_mean = mean ( data ( [1:lower_ts], : ) );
		% average over the first 'lower_ts' time slices
	
	[ rows_data, cols_data ] = size ( data );
		% evaluate size of the input data
		% for the averaging of the last 'upper_ts' time slices
	
	upper_ts_mean = mean ( data ( [(rows_data - upper_ts):rows_data], : ) );
		% average over the last 'upper_ts' time slices


	% Second step: weighted compensation of drift running along B_0

	inverted_drift = -drift + ( 2* ( ( ( max(drift) - min(drift)) / 2) + min(drift) ) );
		% compute 'inverted drift' from drift given as second input parameter
		% The 'original' drift vector is mirrored on the value in the middle 
		% between maximum and minimum.
		% If the drift is plotted against the B_0 field this leads to
		% a constant line (the 'axis of reflection')
	
	for i = 1:rows_data		% for each time slice
	
		data ( i, : ) = data ( i, : ) - (( inverted_drift(i)*lower_ts_mean + drift(i)*upper_ts_mean ) / ((drift(i) + inverted_drift(i))));
			% Compensate drift through weighted subtraction of the first (lower)
			% and last (upper) averaged time slices.
			% This works for every kind of drift (linear and nonlinear).

	end					% end of for loop

%******
