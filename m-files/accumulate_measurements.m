% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/accumulate_measurements.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/09/29
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	DATA = accumulate_measurements ( MATRIX1, MATRIX2, ... )
%
% DESCRIPTION
%	This function gets two or more matrices and sums them up element-wise
%	thus accumulating the measurements to improve the signal to noise ratio.	
%
%	Before summarizing up the matrices the function will test for identical
%	dimensions of the matrices and otherwise return an error message
%
% TODO
%	Instead of simply summarizing this function should check for the best possibility
%	to do this in a way the noise is minimized.
%	This is done by calculating a quality parameter (the ratio of the standard deviation
%	of the off-resonance noise to the maximum signal amplitude) and a weighted addition of
%	both spectra optimized in a way to yield maximum quality measured by the quality parameter.
%
% SOURCE

function data = accumulate_measurements ( matrix1, matrix2, varargin )

  disp ( '$RCSfile$, $Revision$, $Date$' );

  if nargin < 2			% Check number of input arguments.
  
  	fprintf('\nERROR: Function called with less than two input parameters. Aborted.\n')
  
	error ();			% get error if function is called with less than
  						% two input parameters
  end
  
  [ quality_matrix1, amplitude_matrix1, std_noise_matrix1 ] = quality_of_spectrum ( matrix1, 10 )

  [ quality_matrix2, amplitude_matrix2, std_noise_matrix2 ] = quality_of_spectrum ( matrix2, 10 )

  sum_quality = ones(1,100);

  for i = 1:100

    sum = summarize_matrices ( matrix1, matrix2, (i/10) );
  						% in a first step
  						% sum up the first two matrices
  						
  	sum_quality (1,i) = quality_of_spectrum ( sum, 10 );
  	
  end
  
  [ best_quality, index_best_quality ] = max(sum_quality)
  
  data = summarize_matrices ( matrix1, matrix2, (index_best_quality/10) );
  
  [ quality_data, amplitude_data, std_noise_data ] = quality_of_spectrum ( data, 10 )

  
  if nargin > 2			% if the function is called with more than two parameters

	for i = 3 : nargin	% as long as there are unused input parameters
	
		data = summarize_matrices ( data, va_arg () );
						% sum up the matrices
		
	end					% end for
	
  end					% end if
  
  
%******

%###############################################################
% SUBFUNCTIONS

%****if* accumulate_measurements/summarize_matrices

function summarized_matrix = summarize_matrices ( matrix1, matrix2, weight )

% SYNOPSIS
%
%	summarized_matrix = summarize_matrices ( matrix1, matrix 2 )
%
% DESCRIPTION
%
%	This function summarizes up two given matrices MATRIX1 and MATRIX2 and returns
%	the summarized matrix SUMMARIZED_MATRIX. The parameter WEIGHT is used to do a
%	weighted matrix sum in the form
%
%	SUMMARIZED_MATRIX = MATRIX1 + WEIGHT * MATRIX2
%
%	Before the sum operation it is checked whether both matrices are of the same size.
%	Otherwise a warning is printed and the matrix MATRIX1 is returned as result.
%
% SOURCE

  if size(matrix1) == size(matrix2)
  						% if both matrices are of the same size

	summarized_matrix = matrix1 + (weight * matrix2);
  						% sum up the matrices
  						% and return summarized matrix
  else
  
  	fprintf ( '\nWARNING:\n Matrices are not of same size! MATRIX1 returned!\n' )
  						% print warning
  						
  	summarized_matrix = matrix1;
  						% return MATRIX1
  
  end

%*****
