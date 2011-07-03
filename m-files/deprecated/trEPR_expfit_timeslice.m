% Copyright (C) 2006 Till Biskup
%
% This file ist free software.
%
%****f* data_processing.1D/trEPR_expfit_timeslice.m
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
%	$Revision: 260 $
% MODIFICATION DATE
%	$Date: 2006-06-27 17:50:32 +0100 (Di, 27 Jun 2006) $
% KEYWORDS
%	trEPR, fsc2, time slice, exponential decay
%
% SYNOPSIS
%	[ fit_parameters, tmax, t1e, dt1e, fit_function ] = trEPR_expfit_timeslice ( time_slice )
%
% DESCRIPTION
%	This routine takes a time slice and tries to fit an exponential
%	decay of the form
%
%		f(x) = a * exp ( b * x ) + c * exp ( d * x ) + e
%
%	starting with the maximum of the signal. In addition thereto it calculates
%	the time where the signal intensity has decayed to 1/e.
%
% INPUT PARAMETERS
%	time_slice
%		an Nx2 matrix consisting of two colums containing the time axis values
%		in the first column and the signal values in the second column
%
%		Such a matrix is created by the routine trEPR_compensate_timeslice.
%
% OUTPUT PARAMETERS
%	fit_parameters
%		a vector containing the fit parameters from the exponential fit function
%
%	tmax
%		the t value where the signal value is maximal
%
%	t1e
%		the t value where the signal value is decayed to 1/e
%
%	dt1e
%		the time starting from tmax where the signal value is decayed to 1/e
%
%	fit_function
%		an Mx2 matrix consisting of two colums containing the time axis values
%		in the first column and the values of the fit function in the second column
%
%	The values of the parameters tmax and t1e are the time
%	left since the trigger pulse.
%
% DEPENDS ON
%	* lsqcurvefit
%
% EXAMPLE
%	To perform an exponential fit of time_slice and get all the data out of it just
%	typein
%
%		[ fp, tmax, t1e, dt1e, ff ] = trEPR_expfit_timeslice ( time_slice )
%
%	That will give you the fit parameters (fp), the values for t_max, t_(1/e),
%	Delta t_(1/e) and the fit function (ff).
%
% SOURCE

function [ fit_parameters, tmax, t1e, dt1e, fit_function ] = trEPR_expfit_timeslice ( time_slice )

	fprintf('\nFUNCTION CALL: $Id: trEPR_expfit_timeslice.m 260 2006-06-27 16:50:32Z web8 $\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 5 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',nargout);

	end
	
	% check for the right format of the input parameters
	
	[ ts_rows, ts_cols ] = size ( time_slice );
	
	if ts_cols ~= 2

		error('\n\tThe input parameter TIME_SLICE has the wrong format: It has %i instead of 2 columns.\n\tPlease use "help trEPR_expfit_timeslice" to get help.',ts_cols);
	
	end

	% check for the availability of the routines we depend on

	if ( exist('lsqcurvefit') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'B0_spectrum');

	end
	
	
	% restore time parameters from time axis of the time slice
	
		% time parameters are
		%
		% no_points
		%	number of points of the time slice
		% trig_pos
		%	position of the trigger pulse
		% length_ts
		%	length of the time slice in microseconds
		
		% remember:	the time axis starts with negative time,
		% 			is zero at the trigger position
		%			and continues in positive time
	
	length_ts = max(time_slice(:,1)-min(time_slice(:,1)));
	
	no_points = length(time_slice(:,1));
	
	[ val_trig_pos, trig_pos ] = min ( abs( time_slice(:,1) ) );
	
	time_params = [ no_points, trig_pos, length_ts ];
	
	
	% evaluate time position for signal maximum
	
	[ max_signal, tpos_max_signal ] = max( abs( time_slice(:,2) ) );
		% using the abs() function is necessary to allow for
		% negative signal maxima
	
	tmax = time_slice(tpos_max_signal,1);
		% time in microseconds where the signal is at its maximum
	
	% cut part of time slice that should be fitted exponentially
	
	fit_ts = time_slice ( tpos_max_signal:length(time_slice(:,2)) , : );
	
	
	% fit exponential decay function to time slice
	
	monoexpfun = @(x,xdata)x(1)*exp(x(2)*xdata)+x(3);
		% fit function: f(x) = a * exp ( b * x ) + c

	biexpfun = @(x,xdata)x(1)*exp(x(2)*xdata)+x(3)*exp(x(4)*xdata)+x(5);
		% fit function: f(x) = a * exp ( b * x ) + c * exp ( d * x ) + e
	
	options = optimset('TolFun',1e-48);
		% set tolerance of function values to e-8
	
	monoexp_x0 = [ 1, -1, -12 ];
		% set start values for the three fit parameters
		%
		% IMPORTANT NOTE:
		% Because of a bug in the lsqcurvefit function of MATLAB(TM) it is necessary
		% to set at least one start value of the fit parameters outside the given
		% boundaries - otherwise in some cases lsqcurvefit will not fit at all
	
	monoexp_lb = [-10 -10 -10];
		% set lower boundaries for the three fit parameters
	monoexp_ub = [10 10 10];
		% set upper boundaries for the three fit parameters
	
	biexp_x0 = [ 1, -1, 0, 0, -12 ];
		% set start values for the three fit parameters
		%
		% IMPORTANT NOTE:
		% Because of a bug in the lsqcurvefit function of MATLAB(TM) it is necessary
		% to set at least one start value of the fit parameters outside the given
		% boundaries - otherwise in some cases lsqcurvefit will not fit at all
	
	biexp_lb = [-10 -10 -10 -10 -10];
		% set lower boundaries for the three fit parameters
	biexp_ub = [10 10 10 10 10];
		% set upper boundaries for the three fit parameters
	
	[ monoexp_fit_parameters ] = lsqcurvefit ( monoexpfun, monoexp_x0, fit_ts(:,1), fit_ts(:,2),monoexp_lb,monoexp_ub,options);
		% fit with lsqcurvefit

	[ biexp_fit_parameters ] = lsqcurvefit ( biexpfun, biexp_x0, fit_ts(:,1), fit_ts(:,2),biexp_lb,biexp_ub,options);
		% fit with lsqcurvefit
	
	monoexp_t1e = ( log((max_signal/exp(1))/abs(monoexp_fit_parameters(1))) / monoexp_fit_parameters(2));
		% time (in microseconds) where the signal has decayed to 1/e of the maximum
		
	monoexp_dt1e = monoexp_t1e - tmax;
		% time (in microseconds) for the signal to decay to 1/e of the maximum
		% starting from the time where the signal is at its maximum
	
	monoexp_fit_function = [ fit_ts(:,1) monoexpfun(monoexp_fit_parameters,fit_ts(:,1)) ];
		% as fourth parameter return an Mx2 matrix containing the time axis
		% and the function values of the fitted function
	
	biexp_t1e = ( log((max_signal/exp(1))/abs(biexp_fit_parameters(1))) / biexp_fit_parameters(2));
		% time (in microseconds) where the signal has decayed to 1/e of the maximum
		
	biexp_dt1e = biexp_t1e - tmax;
		% time (in microseconds) for the signal to decay to 1/e of the maximum
		% starting from the time where the signal is at its maximum
	
	biexp_fit_function = [ fit_ts(:,1) biexpfun(biexp_fit_parameters,fit_ts(:,1)) ];
		% as fourth parameter return an Mx2 matrix containing the time axis
		% and the function values of the fitted function

	monoexp_fit_parameters

	biexp_fit_parameters
	
	% print fit functions
	
	fprintf('\n\nThe monoexponential fit function was:\n\n     %08.6f * exp ( %08.6f * x ) + %08.6f\n\n',monoexp_fit_parameters);
	
	fprintf('\n\nThe biexponential fit function was:\n\n     %08.6f * exp ( %08.6f * x ) + %08.6f * exp ( %08.6f * x ) + %08.6f\n\n',biexp_fit_parameters);

	fit_parameters = [ [ monoexp_fit_parameters 0 0 ]' biexp_fit_parameters' ];
	t1e = [ monoexp_t1e ; biexp_t1e ];
	dt1e = [ monoexp_dt1e ; biexp_dt1e ];
	fit_function = [ monoexp_fit_function biexp_fit_function ];

	
%******
