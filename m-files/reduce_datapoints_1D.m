% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/reduce_datapoints_1D.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/07/05
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%
%	output = reduce_datapoints_1D ( input, filter_width )
%
% DESCRIPTION
%
%	REDUCE_DATAPOINTS_1D takes the INPUT and averages over FILTER_WIDTH.
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
%		vector containing the data that should be filtered with the
%		running average filter.
%
%	filter_width
%		width of the filter in data points
%
% OUTPUT PARAMETERS
%	output
%		vector containing the filtered input data.
%
%		If FILTER_WIDTH exceeds 1/10 of the dimension of INPUT a warning is printed
%		and the original matrix INPUT is returned unaltered in OUTPUT.
%
%		Similarly, If FILTER_WIDTH exceeds the dimension of INPUT a warning
%		is printed and the original matrix INPUT is returned unaltered in OUTPUT.
%
% SOURCE

function output = reduce_datapoints_1D ( input, filter_width )

	fprintf ( '\nFUNCTION CALL: $Id: reduce_datapoints_1D.m 235 2006-05-30 16:36:41 +0000 (Tue, 30 May 2006) web8 $\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 2)
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help reduce_datapoints_1D" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
			
	end
	
	if ( nargout ~= 1 )
	
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help reduce_datapoints_1D" to get help.',nargout);
			% get error if function is called with other than
			% one output parameter.
	
	end

	
	% check for correct format of the input parameters
	
	% INPUT
	
	if ( ~isvector(input) )
	
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
	
	input_size = length ( input );
	
	
	% typeout some messages in the case that the filter width exceeds
	% the input dimensions or at least 1/10th of the input dimensions.
	
	if ( filter_width > input_size )
	
		fprintf('\nERROR: You are about to average over a range that exceeds the dimensions\nof the input matrix...\n')
		fprintf('\nINFO: The input matrix is returned unaltered\n')
		
		output = input;		% the input matrix is returned unaltered
	
	elseif ( filter_width > (input_size/10) )
	
		fprintf('\nERROR: You are about to average over a range that exceeds 1/10th\nof the dimensions of the input matrix...\n')
		fprintf('\nINFO: The input matrix is returned unaltered\n')

		output = input;		% the input matrix is returned unaltered
	
	% otherwise do the job and average over the input data
	
	else
	
		for i=1:floor(input_size/filter_width)

			output(i) = mean(input( (filter_width*i-(filter_width-1)):i*filter_width ));

		end	
	
	end
	
%******