% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* interactive_programs.general/trEPR_snr.m
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
%	[ snr, signal_amplitude ] = trEPR_snr ( data, [noise_range] )
%
%	[ snr, signal_amplitude, noise_amplitude ] = trEPR_snr ( data, [noise_range] )
%
%	The minimum is one input parameter and one output parameter. The additional
%	second input parameter as well as the second and third output parameter are
%	optional but not necessary.
%
% DESCRIPTION
%	This function computes the signal-to-noise ratio (SNR) of a given spectrum DATA.
%
%	Therefore it takes the data given as first input parameter and depending on the
%	second input parameter defining the part of the spectrum taken as noise
%	it calculates first the noise amplitude (half the difference between maximum and
%	minimum) then the signal amplitude and in the end the ratio of both.
%
% INPUT PARAMETERS
%	data	
%		A vector or a Nx2 matrix containing the spectrum.
%
%		In case of the Nx2 matrix the second column contains the spectrum.
%
%	noise_range (OPTIONAL)
%		A scalar or vector defining the range of the spectrum used to
%		compute the noise amplitude.
%
%		In case of a vector this vector must consist of two values that
%		are used as lower and upper boundary for the part of the spectrum
%		referred to as noise and used to compute the noise amplitude.
%
%		In case of a scalar the value is used as the upper boundary of the
%		noise level.
%
%		If no second parameter is provided at the function call the first fourty
%		data points are taken as noise range.
%
% OUTPUT PARAMETERS
%	snr
%		A scalar containing the signal-to-noise ratio (SNR) of the spectrum
%		provided as first input parameter.
%
%	signal_amplitude
%		The amplitude of the signal calculated as the half-width between the maximum
%		and the minimum of the spectrum.
%
%		signal_amplitude = ( max(spectrum) - min(spectrum) ) / 2
%
%	noise_amplitude
%		The amplitude of the noise calculated as the half-width between the maximum
%		and the minimum of the noise-part of the spectrum.
%
%		noise_amplitude = ( max(noise) - min(noise) ) / 2
%
%		Where noise is a part of the spectrum defined by the second input parameter.
%
% EXAMPLE
%	To compute the SNR of the data data just typein:
%
%		snr = trEPR_snr ( data, [noise_range] )
%
%	where [noise_range] is an optional parameter as described above. In case you're
%	interested as well in the value of the signal_amplitude sig_ampl, typein:
%
%		[ snr, sig_ampl ] = trEPR_snr ( data, [noise_range] )
%
%	and if you want to see as well the noise amplitude noise_ampl, use:
%
%		[ snr, sig_ampl, noise_ampl ] = trEPR_snr ( data, [noise_range] )
%
% SOURCE

function [ snr, varargout ] = trEPR_snr ( data, varargin )

	fprintf ( '\nFUNCTION CALL: $Id$\n\n' );
	
	% check for right number of input and output parameters

	if ( nargin < 1 ) || ( nargin > 2 )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_snd" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if ( nargout < 1 ) || ( nargout > 3 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_snd" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter. This condition makes it possible
			% to call the function without output arguments.
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

	% set noise range boundaries depending on the number and kind of input parameters
	
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
	
	else
		% if the variable NOISE_RANGE is not set yet
		% set it to a default value
	
		noise_start = 1;
		noise_stop = 40;
	
	end
	
	% set noise range and compute noise amplitude
	
	noise = data ( noise_start:noise_stop );
	
	noise_amplitude = ( max(noise)-min(noise) ) / 2;
	
	if ( nargout == 3 )
		% if the user provided three output arguments
		% assign the noise amplitude to the third output argument
	
		varargout{2} = noise_amplitude;
	
	end
	
	% compute signal amplitude
	
	signal_amplitude = ( max(data)-min(data) ) / 2;
	
	if ( nargout >= 2 )
		% if the user provided at least two output arguments
		% assign the signal amplitude to the second output argument
	
		varargout{1} = signal_amplitude;
	
	end
	
	% compute signal to noise ratio (SNR)
	
	snr = signal_amplitude / noise_amplitude;


%******