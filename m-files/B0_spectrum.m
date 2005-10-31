% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/1D_B0_spectrum.m
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
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	[ SPECTRUM, MAX_INDEX ] = B0_spectrum ( INPUT_DATA, AVERAGE_HALF_WIDTH )
%
% DESCRIPTION
%	This function takes a full 2D spectrum INPUT_DATA, evaluates the maximum in both dimensions and
%	returns a B_0 spectrum SPECTRUM at the point MAX_INDEX where the signal amplitude is maximal in t.
%	This spectrum is averaged over (2 * AVERAGE_HALF_WIDTH + 1) time slices to minimize the noise.
%
% SOURCE

function [ spectrum, max_index ] = B0_spectrum ( input_data, average_half_width )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );
  
  % evaluate the maximum of the 2D spectrum in two dimensions
  
  % From the MATLAB documentation:
  % For matrices, MAX(X) is a row vector containing the maximum element
  % from each column.
  % [Y,I] = MAX(X) returns the indices of the maximum values in vector I.
  % If the values along the first non-singleton dimension contain more
  % than one maximal element, the index of the first one is returned.
  % If there are several identical maximum values, the index of the first
  % one found is returned.
  
  [ max_values, max_index ] = max( max( input_data ));
  
  spectrum = mean( input_data( : , max_index-average_half_width : max_index+average_half_width )' );
  
  
  % Just for test purposes: plot the B_0 spectrum
  
  % x = [ 1 : 1 : size( input_data( :, max_index )) ];
  
  % plot(x,spectrum','-',x,zeros(1,length(x)),'-')


%******
