% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/drift_evaluation.m
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
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ drift, polynom_1st_order, polyval_1st_order, polynom_2nd_order, polyval_2nd_order ] = 
%	drift_evaluation ( input_data, no_slices )
%
% DESCRIPTION
%	This function evaluates large-scale drifts across the whole spectrum.
%
%	Therefore its input arguments are a matrix INPUT_DATA containing the
%	biased data and a parameter NO_SLICES for the number of slices (along the B_0 field)
%	to be used for the evaluation computation.
%
% SOURCE

function [ drift, polynom_1st_order, polyval_1st_order, polynom_2nd_order, polyval_2nd_order ] = drift_evaluation ( input_data, no_slices )

  disp ( '$Revision$, $Date$' );

  % First of all, check number of arguments

  if nargin ~= 2
  						% Check number of input arguments.
  
	error('Wrong number of input arguments');
						% get error if function is called with other than
  						% two input parameters
  end

  if nargout ~= 5		% Check number of output arguments.
  
	error('Wrong number of output arguments');
						% get error if function is called with other than
  						% five output parameter
  end


  % First step: Try to evaluate drift along the B_0 axis
  
  [ input_data_rows, input_data_cols ] = size ( input_data );
  						% evaluate size of input data matrix
  
  drift = mean ( input_data (:, [(input_data_cols - no_slices) : input_data_cols])' );
  						% the last 10 B_0 field slices are averaged to compute the drift

  x = [1:1:input_data_rows];		
  						% create x-axis values
  
  polynom_1st_order = polyfit(x,drift,1);
  						% compute 1st order polynomial fit

  polyval_1st_order = polyval(polynom_1st_order,x);
  						% get values from 1st order polynomial fit
  								
  polynom_2nd_order = polyfit(x,drift,2);
						% compute 2nd order polynomial fit

  polyval_2nd_order = polyval(polynom_2nd_order,x);
						% get values from 2nd order polynomial fit


  % do some statistics with the fit data
  
  mean_drift = mean ( drift )
  						% compute (arithmetic) mean of drift
  
  % Now some statistics for the first order fit
  
  first_order_fit = drift - polyval_1st_order;
  						% compute first order fit as difference of drift and
  						% first order polynom
  
  mean_1st_order_fit = mean ( first_order_fit )
  						% compute (arithmetic) mean of first order fit
  								
  var_1st_order_fit = var ( first_order_fit )
  						% compute (real) variance of first order fit
  								
  std_1st_order_fit = std ( first_order_fit )
						% compute standard deviation of first order fit  

  
  % Now some statistics for the second order fit
  
  second_order_fit = drift - polyval_2nd_order;
  						% compute second order fit as difference of drift and
  						% second order polynom
  
  mean_2nd_order_fit = mean ( second_order_fit )
  						% compute (arithmetic) mean of second order fit

  var_2nd_order_fit = var ( second_order_fit )
  						% compute (real) variance of second order fit
  								
  std_2nd_order_fit = std ( second_order_fit )
						% compute standard deviation of second order fit  

  
%******
