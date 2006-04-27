% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* user_routines/trEPR_expfit_timeslice.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/27
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	trEPR, fsc2, time slice, exponential decay
%
% SYNOPSIS
%	[ fit_parameters, tmax, t1e ] = trEPR_expfit_timeslice ( time_slice )
%
% DESCRIPTION
%	This routine takes a time slice and tries to fit an exponential
%	decay starting with the maximum of the signal.
%
% INPUT PARAMETERS
%	time_slice
%		an Nx2 matrix consisting of two colums containing the time axis values
%		in the first column and the signal values in the second column
%
% OUTPUT PARAMETERS
%	fit_parameters
%		a vector containing the fit parameters from the exponential fit function
%	tmax
%		the t value where the signal value is maximal
%	t1e
%		the t value where the signal value is decayed to 1/e
%
% SOURCE

function [ fit_parameters, tmax, t1e ] = trEPR_expfit_timeslice ( time_slice )

	fprintf('FUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 3 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',nargout);

	end
	
	% check for the right format of the input parameters
	
	[ ts_rows, ts_cols ] = size ( time_slice );
	
	if ts_cols ~= 2

		error('\n\tThe input parameter TIME_SLICE has the wrong format: It has %i instead of 2 columns.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',ts_cols);
	
	end
	
	
	% restore time parameters from time axis of the time slice
	
	length_ts = max(time_slice(:,1)-min(time_slice(:,1)));
	
	no_points = length(time_slice(:,1));
	
	[ val_trig_pos, trig_pos ] = min ( abs( time_slice(:,1) ) );
	
	time_params = [ no_points, trig_pos, length_ts];
	
	
	% evaluate time position for signal maximum
	
	[ max_signal, tpos_max_signal ] = max( time_slice(:,2) );
	
	tmax = time_slice(tpos_max_signal,1);
	
	% cut part of time slice that should be fitted exponentially
	
	fit_ts = time_slice ( tpos_max_signal:length(time_slice(:,2)) , : );
	
	
	% fit exponential decay function to time slice
	
	fitfun = @(x,xdata)x(1)*exp(x(2)*xdata);
	
	x0 = [ 1, -1 ];
	
	[ fit_parameters ] = lsqcurvefit ( fitfun, x0, fit_ts(:,1), fit_ts(:,2));
	
%	t1e = log(maxx/exp(1)) / ( abs(fit_parameters(2)) * log(abs(fit_parameters(1))) );

	t1e = ( log((max_signal/exp(1))/abs(fit_parameters(1))) / fit_parameters(2));
	
%******
