
% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/quality_of_spectrum.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/18
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	QUALITY = quality_of_spectrum ( DATA, NUM_TS )
%
% DESCRIPTION
%	This function evaluates the quality of a spectrum by evaluating the ratio
%	between the maximum of the signal amplitude and the standard deviation of the
%	off-resonance noise calculated from the first NUM_TS time slices of the spectrum.
%
% SOURCE

function [ quality, amplitude, std_noise ] = quality_of_spectrum ( data, num_ts )

%  disp ( '$RCSfile$, $Revision$, $Date$' );

  amplitude = max ( max ( data ) );
  
  noise = mean ( data ( [1:num_ts], : ) );
  						% average over the first 'num_ts' time slices
  						
  std_noise = std ( noise );
  						% get standard deviation from the noise
  
  quality = amplitude / std_noise;
  

%******


