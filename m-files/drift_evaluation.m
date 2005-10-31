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
%	[ drift, polyval_1st_order, polyval_2nd_order, polyval_3rd_order, polyval_4th_order, polyval_5th_order, polyval_6th_order, polyval_7th_order ] = 
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

function [ drift, polyval_1st_order, polyval_2nd_order, polyval_3rd_order, polyval_4th_order, polyval_5th_order, polyval_6th_order, polyval_7th_order ] = drift_evaluation ( input_data, no_slices )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$' );

  % First of all, check number of arguments

  if nargin ~= 2
  						% Check number of input arguments.
  
	error('Wrong number of input arguments');
						% get error if function is called with other than
  						% two input parameters
  end

  if nargout ~= 8		% Check number of output arguments.
  
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
  
  fprintf('\nStatistics of the drift evaluation:\n');
  fprintf('\n\t\t\tmean\t\tvar\t\tstd dev\n');
  						% print table header for the following statistical data
  
  mean_drift = mean ( drift );
  						% compute (arithmetic) mean of drift
  						
  fprintf('drift\t\t%i\n', mean_drift);
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

  fprintf('1st order fit\t%i\t%i\t%i\n', mean_1st_order_fit, var_1st_order_fit, std_1st_order_fit);
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

  fprintf('2nd order fit\t%i\t%i\t%i\n', mean_2nd_order_fit, var_2nd_order_fit, std_2nd_order_fit);
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

  fprintf('3rd order fit\t%i\t%i\t%i\n', mean_3rd_order_fit, var_3rd_order_fit, std_3rd_order_fit);
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

  fprintf('4th order fit\t%i\t%i\t%i\n', mean_4th_order_fit, var_4th_order_fit, std_4th_order_fit);
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

  fprintf('5th order fit\t%i\t%i\t%i\n', mean_5th_order_fit, var_5th_order_fit, std_5th_order_fit);
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

  fprintf('6th order fit\t%i\t%i\t%i\n', mean_6th_order_fit, var_6th_order_fit, std_6th_order_fit);
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

  fprintf('7th order fit\t%i\t%i\t%i\n', mean_7th_order_fit, var_7th_order_fit, std_7th_order_fit);
  						% print statistical data

  
%******
