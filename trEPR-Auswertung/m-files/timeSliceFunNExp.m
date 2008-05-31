% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/timeSliceFunNExp.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/21
% VERSION
%	$Revision: 382 $
% MODIFICATION DATE
%	$Date: 2007-06-25 17:29:05 +0200 (Mon, 25 Jun 2007) $
% KEYWORDS
%	trEPR, time slice, multiexponential, full shape simulation
%
% SYNOPSIS
%	timeSliceFunBiExp
%
% DESCRIPTION
%	function for simulating the full time slice (without pretrigger offset) with a
%	function of the form
%
%		ts = 1 - C_1 * exp ( -t / tau_1 ) + ... + C_n * exp ( -t / tau_n )
%
%	with t being the time, C_n being the coefficients
%	and tau_n being the two different time constants.
%
% INPUT PARAMETERS
%	t
%		time axis (vector)
%
%	parameters
%		Nx2 matrix with pairs of values (coefficients C_n and time constants tau_n)
%
% OUTPUT PARAMETERS
%	y
%		values of computed time slice	(vector)
%
% EXAMPLE
%	To simulate and plot a time slice typein something like
%
%		parameters = [1 1; -1 10; -1 0];
%		time = [0:0.04:18];
%		timeSlice = timeSliceFunNExp(time,parameters);
%		plot(time,timeSlice);
%
% SOURCE

function [ y ] = timeSliceFunNExp ( t, parameters )

%-%	fprintf('\nFUNCTION CALL: $Id: timeSliceFunNExp.m 382 2007-06-25 15:29:05Z till $\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help timeSliceFunNExp" to get help.',nargin);

	end

	if ( nargout ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help timeSliceFunNExp" to get help.',nargout);

	end


	% check for correct format of the input parameters

	% T
	
	if ( ~isnumeric(t) || isscalar(t) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help %s" to get help.','t','timeSliceFunNExp');
			% get error if function is called with the wrong format of the
			% input parameter 't'

	% PARAMETERS
	
	elseif ( ~isnumeric(parameters) || isscalar(parameters) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help %s" to get help.','parameters','timeSliceFunNExp');
			% get error if function is called with the wrong format of the
			% input parameter 'parameters'
	
	else
	
		parameters_size = size(parameters);
		parameters_rows = parameters_size(1);
		parameters_cols = parameters_size(2);
	
		if ( parameters_cols ~= 2 )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help %s" to get help.','parameters','timeSliceFunNExp');
				% get error if function is called with the wrong format of the
				% input parameter 'tau3'

		end

	end
	% ...and here the 'real' stuff goes in

	y = zeros(1,length(t));
	for j = 1:parameters_rows
	    y = y + parameters(j,1) * exp(-t/parameters(j,2));
	end

	y = 1-y;
	
	% normalization to maximum of 1
%-%	y = y*(1/max(y));
	
	% "smart" normalization to a maximum around 1
	% This is used to take into account that we have some noise on the experimental
	% data that we can account for in this way.
	[maxValue,maxIndex] = max(y);
	
	normalizationRange = 10;

	% in case that the sum of maxIndex and normalizationRange exceeds
	% the matrix dimensions set the values manually
	if ( maxIndex >= (max(size(y))-normalizationRange) )
		maxIndex = max(size(y)) - normalizationRange - 1;
	elseif ( maxIndex <= normalizationRange )
		maxIndex = normalizationRange + 1;
	end
	
	normalizationFactor = mean(y(1,maxIndex-normalizationRange:1:maxIndex+normalizationRange));
	y = y*(1/normalizationFactor);

	return;

%******
