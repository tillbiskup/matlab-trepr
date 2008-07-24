% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/baseline_subtraction_fsc2.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/03/16
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, baseline subtraction
%
% SYNOPSIS
%	DATA = baseline_subtraction_fsc2 ( data, no_ts )
%
% DESCRIPTION
%	This function subtracts a baseline in the same way the fsc2 programs do:
%	It computes the mean of the first NO_TS time slices and subtracts this mean
%	from every time slice of the 2D spectrum.
%
%	Therefore its input arguments are a matrix INPUT_DATA containing the
%	biased data and the number NO_TS of the time slices that are averaged to yield
%	the baseline that is subtracted.
%
% INPUT
%	data
%		NxM matrix containing the measured data
%
%	no_ts
%		scalar containing the number of time slices that should be used to compute
%		the baseline that is subtracted from the rest of the spectrum
%
% OUTPUT
%	data
%		NxM matrix containing the baseline-subtracted data
%
% EXAMPLE
%	To subtract the baseline in the same way as the fsc2 data recording program for
%	transient EPR spectra of tripletts or radical pairs do just typein:
%
%		data = baseline_subtraction_fsc2 ( data, 10 )
%
% SOURCE

function data = baseline_subtract_fsc2 ( data, no_ts )

	fprintf ( '\nFUNCTION CALL: $Id$\n' );

	% check for right number of input and output parameters

	if nargin ~= 2
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help baseline_subtract_fsc2" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
	end

	if nargout ~= 1
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help baseline_subtract_fsc2" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help baseline_subtract_fsc2" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% NO_TS

	elseif ( ~isnumeric(no_ts) || ~isscalar(no_ts) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help baseline_subtract_fsc2" to get help.','no_ts');
			% get error if function is called with the wrong format of the
			% input parameter 'no_ts'

	end


	% First step: Compute mean values for lower and upper end of B_0 field
	
	[ rows_data, cols_data ] = size ( data );
							% evaluate size of the input data
	
	% Perform only baseline correction if the number of time traces is more than
	% five times bigger than the number of time traces to average for the baseline
	% correction.
	
	if ( rows_data > (no_ts * 5) )

		baseline = mean ( data ( [1:no_ts], : ) );
							% average over the first 'no_ts' time slices
	 
		for i = 1:rows_data		% for each time slice
	
			data ( i, : ) = data ( i, : ) - ( baseline );
							% Compensate drift through weighted subtraction of the first (lower)
							% and last (upper) averaged time slices.
							% This works for every kind of weights (linear and nonlinear).
	
		end					% end of for loop
	
	else
	
		fprintf( ...
		  [ ...
		    '\n' ...
		    'WARNING: The number of time traces of the data given to compensate\n' ...
		    '         is less than five times the number of time traces to\n' ...
		    '         accumulate for the baseline subtraction.\n\n' ...
		    '         Therefore, no baseline subtraction has been performed.' ...
		    '\n' ...
		  ] ...
		);
		
	end

%******
