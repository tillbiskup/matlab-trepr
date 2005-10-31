% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/frequency_compensation.m
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
%	DATA = frequency_compensation ( input_data, actual_frequency, target_frequency )
%
% DESCRIPTION
%	This function compensates for different frequencies used during the measurement.
%	It reads a matrix INPUT_DATA, the ACTUAL_FREQUENCY as read from the fsc2 file and the
%	TARGET_FREQUENCY as read from the fsc2 file from another spectrum.
%
% SOURCE

function data = frequency_compensation ( input_data, actual_frequency, target_frequency )

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$' );
  
  data = input_data * ( actual_frequency / target_frequency );
  
  

%******
