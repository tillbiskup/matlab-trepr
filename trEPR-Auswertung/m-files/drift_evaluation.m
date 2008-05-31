% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/drift_evaluation.m
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
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, drift, polynomial fit
%
% SYNOPSIS
%	[ drift, polyvals ] = drift_evaluation ( data, no_slices )
%
% DESCRIPTION
%	drift_evaluation evaluates large-scale drifts across the whole spectrum.
%
%	Therefore it uses the last NO_SLICES B_0 slices at the time axis, averages over
%	them and fits polynoms of first to seventh order to this drift.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	no_slices
%		scalar containing the number of B_0 slides to use for evaluating the drift.
%
% OUTPUT PARAMETERS
%	drift
%		1xN vector containing the drift of the spectrum evaluated via averaging of
%		the last NO_SLICES B_0 slices in time.
%
%	polyvals
%		Nx7 matrix containing the polynomial fits of the drift for each of the first
%		to the seventh order of polynom
%
% EXAMPLE
%	To evaluate the drift and the polynomial fits of the first to seventh order
%	of the recorded DATA 
%
%	[ drift, polyvals ] = drift_evaluation ( data, 10 )
%
% SOURCE

function [ drift, varargout ] = drift_evaluation ( data, no_slices )

	fprintf ( '\n%% FUNCTION CALL: $Id$\n%% ' );

	% check for right number of input and output parameters

	if nargin ~= 2
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help drift_evaluation" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
	end

	if ( ( nargout ~= 2 ) && ( nargout ~= 8 ) )
		% for compatibility reasons with former versions of this function it is still
		% possible to provide eight output parameters. These return values will be
		% assigned at the end of the function.
	
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help drift_evaluation" to get help.',nargout);
			% get error if function is called with other than
			% eight output parameters
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isvector(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_evaluation" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% NO_SLICES

	elseif ( ~isnumeric(no_slices) || ~isscalar(no_slices) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help drift_evaluation" to get help.','no_slices');
			% get error if function is called with the wrong format of the
			% input parameter 'no_slices'

	end

	% First step: Try to evaluate drift along the B_0 axis
	
	[ data_rows, data_cols ] = size ( data );
							% evaluate size of input data matrix
	
	drift = mean ( data (:, [(data_cols - no_slices) : data_cols])' );
							% the last 10 B_0 field slices are averaged to compute the drift

	x = [1:1:data_rows];		
							% create x-axis values
	
	polynom_1st_order = polyfit(x,drift,1);
							% compute 1st order polynomial fit

	polyval_1st_order = polyval(polynom_1st_order,x);
							% get values from 1st order polynomial fit
									
	polynom_2nd_order = polyfit(x,drift,2);
						% compute 2nd order polynomial fit

	polyval_2nd_order = polyval(polynom_2nd_order,x);
						% get values from 2nd order polynomial fit
									
	polynom_3rd_order = polyfit(x,drift,3);
						% compute 3rd order polynomial fit

	polyval_3rd_order = polyval(polynom_3rd_order,x);
						% get values from 3rd order polynomial fit
									
	polynom_4th_order = polyfit(x,drift,4);
						% compute 4th order polynomial fit

	polyval_4th_order = polyval(polynom_4th_order,x);
						% get values from 4th order polynomial fit
									
	polynom_5th_order = polyfit(x,drift,5);
						% compute 5th order polynomial fit

	polyval_5th_order = polyval(polynom_5th_order,x);
						% get values from 5th order polynomial fit
									
	polynom_6th_order = polyfit(x,drift,6);
						% compute 6th order polynomial fit

	polyval_6th_order = polyval(polynom_6th_order,x);
						% get values from 6th order polynomial fit
									
	polynom_7th_order = polyfit(x,drift,7);
						% compute 7th order polynomial fit

	polyval_7th_order = polyval(polynom_7th_order,x);
						% get values from 7th order polynomial fit


	% do some statistics with the fit data
	
	fprintf('\n%% Statistics of the drift evaluation:\n%% ');
	fprintf('\n%% \t\t\tmean\t\tvar\t\tstd dev\n%% ');
							% print table header for the following statistical data
	
	mean_drift = mean ( drift );
							% compute (arithmetic) mean of drift
							
	fprintf('drift\t\t%i\n%% ', mean_drift);
							% print first row of statistical data
	
	% Now some statistics for the first order fit
	
	first_order_fit = drift - polyval_1st_order;
							% compute first order fit as difference of drift and
							% first order polynom
	
	mean_1st_order_fit = mean ( first_order_fit );
							% compute (arithmetic) mean of first order fit
									
	var_1st_order_fit = var ( first_order_fit );
							% compute (real) variance of first order fit
									
	std_1st_order_fit = std ( first_order_fit );
						% compute standard deviation of first order fit	

	fprintf('1st order fit\t%i\t%i\t%i\n%% ', mean_1st_order_fit, var_1st_order_fit, std_1st_order_fit);
							% print statistical data

	
	% Now some statistics for the second order fit
	
	second_order_fit = drift - polyval_2nd_order;
							% compute second order fit as difference of drift and
							% second order polynom
	
	mean_2nd_order_fit = mean ( second_order_fit );
							% compute (arithmetic) mean of second order fit

	var_2nd_order_fit = var ( second_order_fit );
							% compute (real) variance of second order fit
									
	std_2nd_order_fit = std ( second_order_fit );
						% compute standard deviation of second order fit	

	fprintf('2nd order fit\t%i\t%i\t%i\n%% ', mean_2nd_order_fit, var_2nd_order_fit, std_2nd_order_fit);
							% print statistical data

	
	% Now some statistics for the third order fit
	
	third_order_fit = drift - polyval_3rd_order;
							% compute third order fit as difference of drift and
							% third order polynom
	
	mean_3rd_order_fit = mean ( third_order_fit );
							% compute (arithmetic) mean of third order fit

	var_3rd_order_fit = var ( third_order_fit );
							% compute (real) variance of third order fit
									
	std_3rd_order_fit = std ( third_order_fit );
						% compute standard deviation of third order fit	

	fprintf('3rd order fit\t%i\t%i\t%i\n%% ', mean_3rd_order_fit, var_3rd_order_fit, std_3rd_order_fit);
							% print statistical data

	
	% Now some statistics for the fourth order fit
	
	fourth_order_fit = drift - polyval_4th_order;
							% compute fourth order fit as difference of drift and
							% fourth order polynom
	
	mean_4th_order_fit = mean ( fourth_order_fit );
							% compute (arithmetic) mean of fourth order fit

	var_4th_order_fit = var ( fourth_order_fit );
							% compute (real) variance of fourth order fit
									
	std_4th_order_fit = std ( fourth_order_fit );
						% compute standard deviation of fourth order fit	

	fprintf('4th order fit\t%i\t%i\t%i\n%% ', mean_4th_order_fit, var_4th_order_fit, std_4th_order_fit);
							% print statistical data

	
	% Now some statistics for the fifth order fit
	
	fifth_order_fit = drift - polyval_5th_order;
							% compute fifth order fit as difference of drift and
							% fifth order polynom
	
	mean_5th_order_fit = mean ( fifth_order_fit );
							% compute (arithmetic) mean of fifth order fit

	var_5th_order_fit = var ( fifth_order_fit );
							% compute (real) variance of fifth order fit
									
	std_5th_order_fit = std ( fifth_order_fit );
						% compute standard deviation of fifth order fit	

	fprintf('5th order fit\t%i\t%i\t%i\n%% ', mean_5th_order_fit, var_5th_order_fit, std_5th_order_fit);
							% print statistical data

	
	% Now some statistics for the sixth order fit
	
	sixth_order_fit = drift - polyval_6th_order;
							% compute sixth order fit as difference of drift and
							% sixth order polynom
	
	mean_6th_order_fit = mean ( sixth_order_fit );
							% compute (arithmetic) mean of sixth order fit

	var_6th_order_fit = var ( sixth_order_fit );
							% compute (real) variance of sixth order fit
									
	std_6th_order_fit = std ( sixth_order_fit );
						% compute standard deviation of sixth order fit	

	fprintf('6th order fit\t%i\t%i\t%i\n%% ', mean_6th_order_fit, var_6th_order_fit, std_6th_order_fit);
							% print statistical data

	
	% Now some statistics for the seventh order fit
	
	seventh_order_fit = drift - polyval_7th_order;
							% compute seventh order fit as difference of drift and
							% seventh order polynom
	
	mean_7th_order_fit = mean ( seventh_order_fit );
							% compute (arithmetic) mean of seventh order fit

	var_7th_order_fit = var ( seventh_order_fit );
							% compute (real) variance of seventh order fit
									
	std_7th_order_fit = std ( seventh_order_fit );
						% compute standard deviation of seventh order fit	

	fprintf('7th order fit\t%i\t%i\t%i\n%% ', mean_7th_order_fit, var_7th_order_fit, std_7th_order_fit);
							% print statistical data

	% assign output parameters according to the number of provided parameters
	
	if ( nargout == 2 )
		% If there are only two output parameters provided by calling the function
		% assemble all fitted data in one matrix containing each fit in one column
		% resulting in a Nx7 matrix
		
		varargout{1} = [ polyval_1st_order' polyval_2nd_order' polyval_3rd_order' polyval_4th_order' polyval_5th_order' polyval_6th_order' polyval_7th_order' ];
	
	elseif ( nargout == 8 )
		% For compatibility reasons: If the function is called with 8 output params
		% just assign each polynomial fit to one output parameter.

		varargout{1} = polyval_1st_order;
		varargout{2} = polyval_2nd_order;
		varargout{3} = polyval_3rd_order;
		varargout{4} = polyval_4th_order;
		varargout{5} = polyval_5th_order;
		varargout{6} = polyval_6th_order;
		varargout{7} = polyval_7th_order;
	
	end
%******
