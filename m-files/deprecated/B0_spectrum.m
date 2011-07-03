% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* data_processing.2D/B0_spectrum.m
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
%	$Revision: 462 $
% MODIFICATION DATE
%	$Date: 2007-10-19 14:15:05 +0100 (Fr, 19 Okt 2007) $
% KEYWORDS
%	transient EPR, fsc2, data processing, B_0 spectrum
%
% SYNOPSIS
%	[ spectrum, max_index ] = B0_spectrum ( data, average_half_width )
%
%	[ spectrum, max_index ] = B0_spectrum ( data, average_half_width, t )
%
% DESCRIPTION
%	This function takes a full 2D spectrum DATA, evaluates the maximum 
%	in both dimensions and returns a B_0 spectrum SPECTRUM at the point 
%	MAX_INDEX where the signal amplitude is maximal in t.
%	This spectrum is averaged over (2 * AVERAGE_HALF_WIDTH + 1) 
%	time slices to minimize the noise.
%
%	If a third parameter is provided at the function call it is used as 
%	user-provided t for computing the B_0 spectrum around.
%
% INPUT PARAMETERS
%	data
%		NxM matrix containing the measured data
%
%	average_half_width
%		integer value defining how many B_0 slices would be averaged to the 
%		spectrum given as first output parameter.
%
%	t (OPTIONAL)
%		integer value defining the position in time where the B_0 spectrum is
%		at its maximum. This value is NOT the time in microseconds but the index
%		of the column in the matrix DATA used as first input parameter.
%
%		If not provided the function will calculate it by itself.
%
% OUTPUT PARAMETERS
%	spectrum
%		Nx1 vector containing the B_0 spectrum at its maximum position averaged
%		over (2 * AVERAGE_HALF_WIDTH + 1) B_0 slices.
%
%	max_index
%		position in time where the B_0 spectrum has its maximum.
%		This value is NOT the time in microseconds but the index
%		of the column in the matrix DATA used as first input parameter.
%
%		The spectrum SPECTRUM is averaged over AVERAGE_HALF_WIDTH B_0 slices
%		before and after this point in time.
%
% EXAMPLE
%	without providing the position in time of the maximum of the B_0 spectrum:
%
%		[ spectrum, max_index ] = B0_spectrum ( data, 2 )
%
%	with providing the position in time of the maximum of the B_0 spectrum:
%
%		[ spectrum, max_index ] = B0_spectrum ( data, 2, 100 )
%
% SOURCE

function [ spectrum, max_index ] = B0_spectrum ( data, average_half_width, varargin )

	fprintf ( '%% FUNCTION CALL: $Id: B0_spectrum.m 462 2007-10-19 13:15:05Z till $\n' );

	% check for the right number of input and output parameters

	if ( nargin < 2 || nargin > 3 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help B0_spectrum" to get help.',nargin);

	end

	if ( ( nargout < 1 ) || ( nargout > 2 ) )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help B0_spectrum" to get help.',nargout);

	end

	% check for correct format of the input parameters
	
	% DATA
	
	if ( ~isnumeric(data) || isscalar(data) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help B0_spectrum" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	elseif ( min(size(data)) == 1 )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help B0_spectrum" to get help.','data');
			% get error if function is called with the wrong format of the
			% input parameter 'data'

	% AVERAGE_HALF_WIDTH
	
	elseif ( ~isnumeric(average_half_width) || ~isscalar(average_half_width) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help B0_spectrum" to get help.','average_half_width');
			% get error if function is called with the wrong format of the
			% input parameter 'average_half_width'

	end

	if ( nargin == 3 )
	
		t = varargin {1};
	
		if ( ~isnumeric(t) || ~isscalar(t) )

			error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help B0_spectrum" to get help.','t');
				% get error if function is called with the wrong format of the
				% input parameter 't'

		end
	
	end


	if ( nargin == 2 )			% if the function is called with two parameters

		% evaluate the maximum of the 2D spectrum in two dimensions
	
		% From the MATLAB documentation:
		% For matrices, MAX(X) is a row vector containing the maximum element
		% from each column.
		% [Y,I] = MAX(X) returns the indices of the maximum values in vector I.
		% If the values along the first non-singleton dimension contain more
		% than one maximal element, the index of the first one is returned.
		% If there are several identical maximum values, the index of the first
		% one found is returned.
	
		[ max_values, max_index ] = max( max( data ));

		% The max_index is used as center for the accumulation of several B_0 spectra.
		% Therefore it becomes a problem when the max_index is at the end of the time axis.
		% To avoid the problem in this case the max_index is shifted.

		[ rows,cols ] = size( data );
		
		if ( (max_index+average_half_width) > cols )
	
			max_index = max_index - average_half_width;
		
		elseif ( (max_index-average_half_width) < cols )
	
			max_index = max_index + average_half_width;
	
		end;
	
		spectrum = mean( data( : , max_index-average_half_width : max_index+average_half_width )' );
	
	elseif ( nargin == 3 )	% if the function is called with three parameters
		
		max_index = t;

		spectrum = mean( data( : , t-average_half_width : t+average_half_width )' );
		
	end					% end if


%******
