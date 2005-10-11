% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/drift_compensation.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/07
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	DATA = drift_compensation ( input_data, weights, lower_ts, ... )
%
% DESCRIPTION
%	This function compensates for large-scale drifts across the whole spectrum.
%
%	Therefore its input arguments are a matrix INPUT_DATA containing the
%	biased data, a vector WEIGHTS with the weights for the compensation computation,
%	and one ore more parameters for the number of time slices to be
%	used for the compensation computation.
%
%	If only one further parameter beyond the matrix with the input data and the weights vector
%	is given both values for the number of time slices at the lower and the upper end of the
%	B_0 field is set to the given parameter LOWER_TS.
%
% SOURCE

function data = drift_compensation ( input_data, weights, lower_ts, varargin )

  % First of all, check number of arguments

  if (nargin < 3) | (nargin > 4)
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

  if nargin == 3			% if number of input arguments is two
  
  	upper_ts = lower_ts;	
  						% set number of time slices at the upper end of the B_0 field
  						% to the number of time slices at the lower end of the field
  	
  else					% else (that is, if number of input arguments is three)
  
	upper_ts = varargin{1}(1)
  						% set number of time slices at the upper end of the B_0 field
  						% to the value given by third parameter

  end


  % First step: Compute mean values for lower and upper end of B_0 field
  
  lower_ts_mean = mean ( input_data ( [1:lower_ts], : ) );
  						% average over the first 'lower_ts' time slices
  
  [ rows_data, cols_data ] = size ( input_data );
  						% evaluate size of the input data
  						% for the averaging of the last 'upper_ts' time slices
  
  upper_ts_mean = mean ( input_data ( [(rows_data - upper_ts):rows_data], : ) );
  						% average over the last 'upper_ts' time slices


  % Second step: weighted compensation of drift running along B_0

  inverted_weights = -weights + ( 2* ( ( ( max(weights) - min(weights)) / 2) + min(weights) ) );
  						% compute 'inverted weights' from weights given as
  						% second input parameter
  						% The 'original' weights vector is mirrored on the value
  						% in the middle between maximum and minimum.
  						% If the weights are plotted against the B_0 field this leads to
  						% a constant line (the 'axis of reflection')
  
  for i = 1:rows_data		% for each time slice
  
  	data ( i, : ) = input_data ( i, : ) - (( inverted_weights(i)*lower_ts_mean + weights(i)*upper_ts_mean ) / ((weights(i) + inverted_weights(i))));
  						% Compensate drift through weighted subtraction of the first (lower)
  						% and last (upper) averaged time slices.
  						% This works for every kind of weights (linear and nonlinear).
  
  end					% end of for loop

%******
