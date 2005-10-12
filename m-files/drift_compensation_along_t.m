% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/drift_compensation_along_t.m
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
%	DATA = drift_compensation_along_t ( input_data, trigger_pos, stable_t, no_ts, drift )
%
% DESCRIPTION
%	This function compensates for large-scale drifts across the whole spectrum.
%
%	Therefore its input arguments are a matrix INPUT_DATA containing the
%	biased data and the variable TRIGGER_POS with the trigger position along the time axis.
%	The argument STABLE_T holds the position along the time axis from where on the signal
%	is stable over time. The argument NO_TS holds the number of time slices used for averaging
%	the signal used to determine t_1.
%
%
% SOURCE

function data = drift_compensation_along_t ( input_data, trigger_pos, stable_t, no_ts, drift )

  % First of all, check number of arguments

  if nargin ~= 5
  						% Check number of input arguments.
  
	error('Wrong number of input arguments');
						% get error if function is called with other than
  						% five input parameters
  end

  if nargout ~= 1		% Check number of output arguments.
  
	error('Wrong number of output arguments');
						% get error if function is called with other than
  						% one output parameter
  end


  % First step: Compute mean values for lower end of B_0 field
  
  ts_mean = mean ( input_data ( [1:no_ts], : ) );
  						% average over the first 'no_ts' time slices


  % Second step: determine t1
  
  [ ts_mean_rows, ts_mean_cols ] = size ( ts_mean );
  						% determine size of ts_mean
  
  upper_t_mean = mean ( ts_mean( [ stable_t : ts_mean_cols ] ) );
  						% compute (arithmetic) mean of t for t >> t_1
  
  upper_t_std = std ( ts_mean( [ stable_t : ts_mean_cols ] ) );
  						% compute standard deviation of t for t >> t_1
  						
  threshold = upper_t_mean - upper_t_std;
  						% compute threshold for determining t_1
  
  i = trigger_pos;		% set start point of while loop to trigger position
  
  while ( ts_mean(i) < threshold )
  						% while value of ts_mean for given position i is smaller than
  						% the above computed threshold
  
  	t_1 = i;			% set t_1 = i
  	
  	i = i+1;				% increment i
  
  end
  
  % set slope of weights
  
  slope_of_weights = 1 / ( t_1 - trigger_pos );
  
  
  % create vectors with weights
  
  for i = (1 : (trigger_pos-1))
  
  	drift_weights(i) = 0;
  
  end
  
  for i = ( trigger_pos : (t_1 - 1))

  	drift_weights(i) = (i-trigger_pos+1) * slope_of_weights;

  end

  for i = ( t_1 : ts_mean_cols )

  	drift_weights(i) = 1;

  end


  % drift compensation

  for i= 1 : ts_mean_cols
  						% for all time points

	data (:, i) = input_data ( :, i ) - ( drift_weights(i) * drift' ) ;
						% subtract values of drift weighted by drift_weights
						% from the input data
  
  end 					% end of for loop

%******
