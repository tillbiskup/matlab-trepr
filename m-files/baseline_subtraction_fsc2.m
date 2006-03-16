% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/baseline_subtraction_fsc2.m
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
%	DATA = baseline_subtraction_fsc2 ( input_data, no_ts )
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
% SOURCE

function data = baseline_subtract_fsc2 ( input_data, no_ts )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );

  % First of all, check number of arguments

  if nargin ~= 2
  						% Check number of input arguments.
  
	error('Wrong number of input arguments');
						% get error if function is called with less than than
  						% three or more than four input parameters
  end

  if nargout ~= 1		% Check number of output arguments.
  
	error('Wrong number of output arguments');
						% get error if function is called with other than
  						% one output parameter
  end


  % First step: Compute mean values for lower and upper end of B_0 field
  
  baseline = mean ( input_data ( [1:no_ts], : ) );
  						% average over the first 'no_ts' time slices
  
  [ rows_data, cols_data ] = size ( input_data );
  						% evaluate size of the input data
   
  for i = 1:rows_data		% for each time slice
  
  	data ( i, : ) = input_data ( i, : ) - ( baseline );
  						% Compensate drift through weighted subtraction of the first (lower)
  						% and last (upper) averaged time slices.
  						% This works for every kind of weights (linear and nonlinear).
  
  end					% end of for loop

%******
