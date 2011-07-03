
% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/quality_of_spectrum.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/18
% VERSION
%	$Revision: 259 $
% MODIFICATION DATE
%	$Date: 2006-06-22 13:20:50 +0100 (Do, 22 Jun 2006) $
% KEYWORDS
%	transient EPR, fsc2, quality of spectrum, SNR
%
% SYNOPSIS
%	QUALITY = quality_of_spectrum ( DATA, NUM_TS )
%
% DESCRIPTION
%	This function evaluates the quality of a spectrum by evaluating the ratio
%	between the maximum of the signal amplitude and the standard deviation of the
%	off-resonance noise calculated from the first NUM_TS time slices of the spectrum.
%
% INPUT PARAMETERS
%	data
%		NxM matrix or Nx1 vector containing the measured data
%
%	num_ts
%		scalar defining the range from the begin of the spectrum that will be taken
%		as the noise part to compute the noise level
%
% OUTPUT PARAMETERS
%	quality
%		scalar representing the quality of the spectrum
%
% EXAMPLE
%	To obtain the quality QUALITY of the spectrum SPECTRUM just type:
%
%		quality = quality_of_spectrum ( spectrum, 20 )
%
% SOURCE

function [ quality, amplitude, std_noise ] = quality_of_spectrum ( data, num_ts )

%	fprintf ( '\n$Id: quality_of_spectrum.m 259 2006-06-22 12:20:50Z web8 $\n' );

	% check for the right number of input and output parameters

	if ( nargin ~= 2 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help quality_of_spectrum" to get help.',nargin);

	end

	if ( ( nargout < 1 ) || ( nargout > 3 ) )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help quality_of_spectrum" to get help.',nargout);

	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help quality_of_spectrum" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'
	
	% NUM_TS
	
	elseif ( ~isnumeric(num_ts) || ~isscalar(num_ts) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help quality_of_spectrum" to get help.','num_ts');
			% get error if function is called with the wrong format of the
			% input parameter 'num_ts'

	end	
	
	% convert row to column vector if DATA is a 1xN vector
	
	[ rows, cols ] = size ( data );
	
	if ( rows == 1 )
	
		data = data';
		[ rows, cols ] = size ( data );
		
		amplitude = max ( data ) + abs( min (data) );

	else
	
		amplitude = max ( max ( data ) ) + abs(min ( min (data) ));
	
	end

	mean_ts = mean ( data ( [1:num_ts], : ) );
							% average over the first 'num_ts' time slices
	
	% noise detection dependend on 1D or 2D data
	
	if ( cols == 1 )
	
		noise = data ( [1:num_ts] );
		
		std_noise = std ( noise );
	
	else
	
		noise = data ( round(num_ts/2), : ) - mean_ts;
							% the middle time slice is taken and the average of the first 'num_ts'
							% time slices subtracted to get a noise around zero
							
		std_noise = std ( noise );
							% get standard deviation from the noise
							
	end
	
	quality = amplitude / std_noise;
	

%******


