% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****m* auxilliary_routines/stop_logging.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/24
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2
%
% SYNOPSIS
%	stop_logging
%
% DESCRIPTION
%	This function is the pendant to the function "start_logging" and is created for integrity.
%	In the moment it is just a primitive call stopping the logging via the in-build diary functionality.
%
% SEE ALSO
%	start_logging
%
% SOURCE

function stop_logging

  fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n' );
  
  diary ( 'off' );		% logging via the diary function stopped

%******
