% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/pretrigger_offset.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/09/28
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	DATA = pretrigger_offset ( input_data, trigger_pos )
%
% DESCRIPTION
%	This function compensates for large-scale oscillations and drifts that affect
%	both the signal and the pretrigger signal (dark signal before laser pulse).
%
% SOURCE

function data = pretrigger_offset ( input_data, trigger_pos )

  disp ( '$RCSfile$, $Revision$, $Date$' );

  % First of all, check number of arguments

  if nargin ~= 2			% Check number of input arguments.
  
	error();				% get error if function is called with other than
  						% two input parameters
  end

  if nargout ~= 1		% Check number of output arguments.
  
	error();				% get error if function is called with other than
  						% one output parameter
  end

  % extract pretrigger signal from input_data
  
  pretrigger_signal = input_data ( :, [1:(trigger_pos-5)] );


  % First step: Compute mean value for complete pretrigger signal

  whole_mean = mean ( mean ( pretrigger_signal' ) );
  
  % Second step: compute mean value for pretrigger signal of a single time slice
  %              for each timeslice and subtract difference to mean value for complete
  %              trigger signal

  [ rows_ps, cols_ps ] = size ( pretrigger_signal );

  for i = 1:( rows_ps )	% For all values of B_0
  
  	ts_mean = mean ( pretrigger_signal( i, : ) );
  						% compute mean value of pretrigger signal of single time slice
  						
  	difference = ts_mean - whole_mean;
  						% compute difference of mean values of single time slice and
  						% whole pretrigger signal
  						
    data (i,:) = input_data (i,:) - ts_mean; %- difference;
    						% subtract difference from input data for each time slice

  end
  

%******
