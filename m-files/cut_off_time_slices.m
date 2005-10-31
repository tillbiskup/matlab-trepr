% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/cut_off_time_slices.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/25
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ DATA, FIELD_PARAMS ] = cut_off_time_slices ( input_data, no_first_time_slices, no_last_time_slices, input_field_params )
%
% DESCRIPTION
%	This function cuts off time slices from the start and the end of a given matrix 
%	INPUT_DATA and returns the matrix DATA with cut off start and end.
%
%	This is useful for large drifts that can easily be compensated by cutting of the first
%	and/or the last time slices.
%
% SOURCE

function [ data, field_params ] = cut_off_time_slices ( input_data, no_first_time_slices, no_last_time_slices, input_field_params )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );
  
  [ ts, bs ] = size(input_data);
  						% determine size of input matrix
  
  data = input_data ( (1+no_first_time_slices) : (ts-no_last_time_slices) , : );
  						% write data as cut off input matrix

  if ( input_field_params(2) > input_field_params(1) )
  
    field_params = [ ( input_field_params(1) + (no_first_time_slices*(abs(input_field_params(3)))) ) ( input_field_params(2) - (no_last_time_slices*(abs(input_field_params(3)))) ) input_field_params(3) ];
  						% set new field parameters
  						% cause the start and end of the B_0 field has (possibly) changed
  						% due to the cut off of time slices
  
  else 
  
    field_params = [ ( input_field_params(1) - (no_last_time_slices*(abs(input_field_params(3)))) ) ( input_field_params(2) + (no_first_time_slices*(abs(input_field_params(3)))) ) input_field_params(3) ];
  						% set new field parameters
  						% cause the start and end of the B_0 field has (possibly) changed
  						% due to the cut off of time slices

  end
  
%******
