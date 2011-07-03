% Copyright (C) 2008 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/trEPR_timeAxis.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2008 Till Biskup
%	This file is free software
% CREATION DATE
%	2008/01/28
% VERSION
%	$Revision: 552 $
% MODIFICATION DATE
%	$Date: 2008-02-26 19:45:14 +0000 (Di, 26 Feb 2008) $
% KEYWORDS
%	trEPR, fsc2, time_params, time axis
%
% SYNOPSIS
%	[ ta ] = trEPR_timeAxis ( time_params )
%
% DESCRIPTION
%	This function is aimed to create a vector for the time axis
%	from the given time_params vector read out from an fsc2 file.
%
% INPUT PARAMETERS
%	time_params
%
% OUTPUT PARAMETERS
%	ta (vector)
%		vector with values for the time axis of the given spectrum
%
% EXAMPLE
%	
%
%
% SOURCE

function [ ta ] = trEPR_timeAxis ( time_params )

	fprintf('\n%% FUNCTION CALL: $Id: trEPR_timeAxis.m 552 2008-02-26 19:45:14Z till $\n%%\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 1 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_timeAxis" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_timeAxis" to get help.',nargout);

	end


	% check for correct format of the input parameters


	% Uncomment the following lines if necessary

	if ( ~isnumeric(time_params) || ~isvector(time_params) || isscalar(time_params) )

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help trEPR_timeAxis" to get help.','time_params');

	end


	% ...and here the 'real' stuff goes in

    ta = linspace ((-time_params(3)/time_params(1)*time_params(2))+(time_params(3)/time_params(1)),time_params(3)-time_params(3)/time_params(1)*time_params(2),time_params(1));

end % end of main function

%******
