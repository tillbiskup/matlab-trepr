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
%	DATA = drift_compensation ( input_data, lower_ts, ... )
%
% DESCRIPTION
%	This function compensates for large-scale drifts across the whole spectrum.
%
%	Therefore its input arguments are a matrix INPUT_DATA containing the
%	biased data and one ore more parameters for the number of time slices to be
%	used for the compensation computation.
%
%	If only one further parameter beyond the matrix with the input data is given
%	both values for the number of time slices at the lower and the upper end of the
%	B_0 field is set to the given parameter LOWER_TS.
%
% SOURCE

function data = drift_compensation ( input_data, lower_ts, varargin )

  % First of all, check number of arguments

  if (nargin < 2) | (nargin > 3)
  						% Check number of input arguments.
  
	error('Wrong number of input arguments');
						% get error if function is called with less than than
  						% two or more than three input parameters
  end

  if nargout ~= 1		% Check number of output arguments.
  
	error('Wrong number of output arguments');
						% get error if function is called with other than
  						% one output parameter
  end

  if nargin == 2			% if number of input arguments is two
  
  	upper_ts = lower_ts	
  						% set number of time slices at the upper end of the B_0 field
  						% to the number of time slices at the lower end of the field
  	
  else					% else (that is, if number of input arguments is three)
  
	upper_ts = varargin{1}(1)
  						% set number of time slices at the upper end of the B_0 field
  						% to the value given by third parameter

  end


  % First step: Compute mean values for lower and upper end of B_0 field
  
  lower_ts_mean = mean ( input_data ( [1:lower_ts], : ) );
  
  [ rows_data, cols_data ] = size ( input_data );
  
  upper_ts_mean = mean ( input_data ( [(rows_data - upper_ts):rows_data], : ) );


  % Second step: weighted compensation of drift running along B_0
  
  for i = 1:rows_data
  
  	data ( i, : ) = input_data ( i, : ) - (( (rows_data + 1 - i)*lower_ts_mean + i*upper_ts_mean ) / (rows_data + 1));
  
  end

%******
