% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/09/29
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2
%
%
% ACCUMULATE_MEASUREMENTS reads two or more matrices and sums them up
%
%	usage: DATA = accumulate_measurements ( MATRIX1, MATRIX2, ... )
%
%	This function gets two or more matrices and sums them up element-wise
%	thus accumulating the measurements to improve the signal to noise ratio.	
%
%	before summarizing up the matrices the function will test for identical
%	dimensions of the matrices and otherwise return an error message

function data = accumulate_measurements ( matrix1, matrix2, varargin )

  if nargin < 2			% Check number of input arguments.
  
	error();				% get error if function is called with less than
  						% two input parameters
  end
  
  data = summarize_matrices ( matrix1, matrix2 );
  						% in a first step
  						% sum up the first two matrices
  
  if nargin > 2			% if the function is called with more than two parameters

	for i = 3 : nargin	% as long as there are unused input parameters
	
		data = summarize_matrices ( data, va_arg () )
						% sum up the matrices
		
	end					% end for
	
  end					% end if
  
  
%###############################################################
% SUBFUNCTIONS

function summarized_matrix = summarize_matrices ( matrix1, matrix2 )

  % This function summarizes up two given matrices MATRIX1 and MATRIX2 and returns
  % the summarized matrix SUMMARIZED_MATRIX.
  %
  % Before the sum operation it is checked whether both matrices are of the same size.
  % Otherwise a warning is printed and the matrix MATRIX1 is returned as result.

  if size(matrix1) == size(matrix2)
  						% if both matrices are of the same size

	summarized_matrix = matrix1 + matrix2;
  						% sum up the matrices
  						% and return summarized matrix
  else
  
  	fprintf ( '\nWARNING:\n Matrices are not of same size! MATRIX1 returned!\n' )
  						% print warning
  						
  	summarized_matrix = matrix1;
  						% return MATRIX1
  
  end
