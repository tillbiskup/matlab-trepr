% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* general.logging/stop_logging.m
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
%	$Revision: 532 $
% MODIFICATION DATE
%	$Date: 2008-02-25 12:53:34 +0000 (Mo, 25 Feb 2008) $
% KEYWORDS
%	diary, logging
%
% SYNOPSIS
%	stop_logging
%
% DESCRIPTION
%	This function is the pendant to the function "start_logging" and is created
%	for integrity.
%
%	In the moment it is just a primitive call stopping the logging via the builtin
%	diary functionality.
%
% INPUT
%	There are no input arguments at the moment
%
% OUTPUT
%	There are no output arguments at the moment
%
% EXAMPLE
%	To stop logging all outputs just typein
%
%		stop_logging
%
% SEE ALSO
%	start_logging
%
% SOURCE

function stop_logging

	fprintf ( '%%\n%% FUNCTION CALL: $Id: stop_logging.m 532 2008-02-25 12:53:34Z till $\n' );

	% check for right number of input and output parameters

	if nargin ~= 0
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help stop_logging" to get help.',nargin);
			% get error if function is called with other than
			% zero input parameters
	end

	if nargout ~= 0
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help stop_logging" to get help.',nargout);
			% get error if function is called with other than
			% zero output parameters
	end
  
	diary ( 'off' );		% logging via the diary function stopped

%******
