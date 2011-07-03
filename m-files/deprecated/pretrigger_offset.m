% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/pretrigger_offset.m
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
%	$Revision: 291 $
% MODIFICATION DATE
%	$Date: 2006-07-28 16:06:13 +0100 (Fr, 28 Jul 2006) $
% KEYWORDS
%	transient EPR, fsc2, pretrigger offset, compensate pretrigger offset
%
% SYNOPSIS
%	DATA = pretrigger_offset ( data, trigger_pos )
%
% DESCRIPTION
%	This function compensates for large-scale oscillations and drifts that affect
%	both the signal and the pretrigger signal (dark signal before laser pulse).
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	trigger_pos
%		scalar giving the index of the column of the matrix DATA where the trigger
%		pulse for the recording of the spectrum lay
%
% OUTPUT PARAMETERS
%	data
%		NxM matrix containing the pretrigger-offset compensated data
%
% EXAMPLE
%	To get the offset-compensated data out of the matrix DATA just typein:
%
%		data = pretrigger_offset ( data, trigger_pos )
%
%	where trigger_pos is the position of the trigger pulse in time
%
% SOURCE

function data = pretrigger_offset ( data, trigger_pos )

	fprintf ( '\n%% FUNCTION CALL: $Id: pretrigger_offset.m 291 2006-07-28 15:06:13Z web8 $\n%% ' );

	% check for right number of input and output parameters

	if nargin ~= 2
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help pretrigger_offset" to get help.',nargin);
			% get error if function is called with other than
			% three input parameters
	end

	if nargout ~= 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help pretrigger_offset" to get help.',nargout);
			% get error if function is called with other than
			% two output parameters
	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help pretrigger_offset" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% TRIGGER_POS

	elseif ( ~isnumeric(trigger_pos) || ~isscalar(trigger_pos) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help pretrigger_offset" to get help.','trigger_pos');
			% get error if function is called with the wrong format of the
			% input parameter 'trigger_pos'

	end

	% extract pretrigger signal from data
	
	pretrigger_signal = data ( :, [1:(trigger_pos-5)] );


	% First step: Compute mean value for complete pretrigger signal

	whole_mean = mean ( mean ( pretrigger_signal' ) );
	
	% Second step: compute mean value for pretrigger signal of a single time slice
	%							for each timeslice and subtract difference to mean value for complete
	%							trigger signal

	[ rows_ps, cols_ps ] = size ( pretrigger_signal );

	for i = 1:( rows_ps )	% For all values of B_0
	
		ts_mean = mean ( pretrigger_signal( i, : ) );
							% compute mean value of pretrigger signal of single time slice
							
		difference = ts_mean - whole_mean;
							% compute difference of mean values of single time slice and
							% whole pretrigger signal
							
		data (i,:) = data (i,:) - ts_mean; %- difference;
								% subtract difference from input data for each time slice

	end
	
%******
