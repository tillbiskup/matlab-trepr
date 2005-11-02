% Copyright (C) 2004,2005 Peter J. Acklam, Till Biskup
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
% SOURCE

function output = running_average ( input, filter_width )

  [row,col] = size ( input );
  						% evaluate dimensions of input matrix
  
  if ( filter_width > row )
  
    fprintf('\nERROR: You are about to average over a range that exceeds the dimensions\nof the input matrix...\n')
    fprintf('\nINFO: The input matrix is returned unaltered\n')
    
    output = input;		% the input matrix is returned unaltered
  
  elseif ( filter_width > (row/10) )
  
    fprintf('\nERROR: You are about to average over a range that exceeds 1/10th\nof the dimensions of the input matrix...\n')
    fprintf('\nINFO: The input matrix is returned unaltered\n')

    output = input;		% the input matrix is returned unaltered
  
  else
  
    average_matrix = zeros (col,row-filter_width+1)';
  						% initialize average_matrix with proper dimensions
  
    for i=1:filter_width

      average_matrix = average_matrix + input ( i:row-filter_width+i, : );

    end  
  
    output = average_matrix/filter_width;
  
  end
  
%******