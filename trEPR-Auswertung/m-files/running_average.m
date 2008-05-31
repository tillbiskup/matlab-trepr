% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/running_average.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/11/01
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%
%	output = running_average ( input, filter_width )
%
% DESCRIPTION
%
%	RUNNING_AVERAGE takes the INPUT and averages over FILTER_WIDTH.
%	The result is returned in OUTPUT.
%
%	If FILTER_WIDTH exceeds 1/10 of the dimension of INPUT a warning is printed
%	and the original matrix INPUT is returned unaltered in OUTPUT.
%
%	Similarly, If FILTER_WIDTH exceeds the dimension of INPUT a warning is printed
%	and the original matrix INPUT is returned unaltered in OUTPUT.
%
% INPUT PARAMETERS
%	input
%		vector or matrix containing the data that should be filtered with the
%		running average filter.
%
%		Given a matrix the filter will run along the rows of this matrix.
%
%	filter_width
%		width of the filter in data points
%
% OUTPUT PARAMETERS
%	output
%		vector or matrix (depending on the INPUT parameter) containing the filtered
%		input data.
%
%		If FILTER_WIDTH exceeds 1/10 of the dimension of INPUT a warning is printed
%		and the original matrix INPUT is returned unaltered in OUTPUT.
%
%		Similarly, If FILTER_WIDTH exceeds the dimension of INPUT a warning
%		is printed and the original matrix INPUT is returned unaltered in OUTPUT.
%
% SOURCE

function output = running_average ( input, filter_width )

	fprintf ( '\nFUNCTION CALL: $Id$\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 2)
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help running_average" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
			
	end
	
	if ( nargout ~= 1 )
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help running_average" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter.
	
	end

	
	% check for correct format of the input parameters
	
	% INPUT
	
	if ( ~isvector(input) && ~ismatrix(input) )
	
		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_timeslice" to get help.','input');
			% get error if function is called with the wrong format of the
			% input parameter 'input'

	% FILTER_WIDTH

	elseif ~isscalar(filter_width)

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help ascii_save_timeslice" to get help.','filter_width');
			% get error if function is called with the wrong format of the
			% input parameter 'filter_width'

	end

	% evaluate dimensions of input matrix
	
	[row,col] = size ( input );
	
	
	% typeout some messages in the case that the filter width exceeds
	% the input dimensions or at least 1/10th of the input dimensions.
	
	if ( filter_width > row )
	
		fprintf('\nERROR: You are about to average over a range that exceeds the dimensions\nof the input matrix...\n')
		fprintf('\nINFO: The input matrix is returned unaltered\n')
		
		output = input;		% the input matrix is returned unaltered
	
	elseif ( filter_width > (row/10) )
	
		fprintf('\nERROR: You are about to average over a range that exceeds 1/10th\nof the dimensions of the input matrix...\n')
		fprintf('\nINFO: The input matrix is returned unaltered\n')

		output = input;		% the input matrix is returned unaltered
	
	% otherwise do the job and average over the input data
	
	else
	
		% initialize average_matrix with proper dimensions
		average_matrix = zeros (col,row-filter_width+1)';
	
		for i=1:filter_width

			average_matrix = average_matrix + input ( i:row-filter_width+i, : );

		end	
	
		output = average_matrix/filter_width;
	
	end
	
%******