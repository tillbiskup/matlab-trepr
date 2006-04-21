% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/trEPR_snr.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/20
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, SNR
%
% SYNOPSIS
%	snr = trEPR_snr ( data, [noise_range] )
%
% DESCRIPTION
%	This function computes the signal to noise ratio (SNR) of a given spectrum DATA.
%
% INPUT PARAMETERS
%	data	
%		A vector or a Nx2 matrix containing the spectrum.
%
%		In case of the Nx2 matrix the second column contains the spectrum.
%
%	noise_range
%		A scalar or vector defining the range of the spectrum used to
%		compute the noise amplitude.
%
%		In case of a vector this vector must consist of two values that
%		are used as lower and upper boundary for the part of the spectrum
%		referred to as noise and used to compute the noise amplitude.
%
% SOURCE

function snr = trEPR_snr ( data, varargin )

	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n' );
	
	% check for right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 2 )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_snd" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if ( nargout > 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_snd" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter. This condition makes it possible
			% to call the function without output arguments.
	end
	
	if nargin == 2
		% in the case that we are called with two input parameters
		% set the value of the second input parameter as variable
		% noise_range
		
		if ~isscalar(varargin{1})
			% in the case that the second input parameter is not a
			% scalar but a vector
		
			if max(size(varargin{1})) ~= 2
				% if the vector consists of more than two values

				error('\n\tThe function is called with a wrong range for noise amplitude computation.\n\tPlease use "help trEPR_snd" to get help.',nargin);
					% get error if the second parameter is a vector
					% with more than two values
			
			else
			
				noise_start = min(varargin{1});
				noise_stop = max(varargin{1});
				
				% set noise_start and noise_stop respectively
			
			end
		
		else
		
			noise_start = 1;
			noise_stop = varargin{1};
			
		end
	
	end

	% check for right format of input parameters
	
	if ~isnumeric(data) || isscalar(data)
  
		error('\n\tThe function is called with the wrong kind of input arguments.\n\tPlease use "help trEPR_snd" to get help.',nargin);
			% get error if function is called with other than
			% a numeric input parameter
	end

	% test whether DATA is a vector or a matrix
	
	if ~isvector(data)
		% in the case that DATA is not a vector
		% that means that it has to be a matrix
		% cause of the check for be numeric and not a scalar,
		% see above
	
		if min(size(data)) > 2 
		
			error('\n\tThe function is called with the wrong kind of input arguments.\n\tPlease use "help trEPR_snd" to get help.',nargin);
				% get error if function is called with other than
				% a numeric input parameter

		else
		
			data = data(:,2);
			% set data to the second column of the input matrix
			% thus assuming that DATA comes from a file written with
			% ascii_save_spectrum.m that writes the B_0 field as first
			% and the values as second column.
		
		end
	
	end
	
	if ~exist('noise_start') && ~exist('noise_stop')
		% if the variable NOISE_RANGE is not set yet
		% set it to a default value
	
		noise_start = 1;
		noise_stop = 40;
	
	end
	
	% set noise range and compute noise amplitude
	
	noise = data ( noise_start:noise_stop );
	
	noise_amplitude = ( max(noise)-min(noise) ) / 2;
	
	% compute signal amplitude
	
	signal_amplitude = ( max(data)-min(data) ) / 2;
	
	% compute signal to noise ratio (SNR)
	
	snr = signal_amplitude / noise_amplitude;


%******