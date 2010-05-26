% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/trEPRinfo.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/01/31
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	trEPR toolbox, trEPR
%
% SYNOPSIS
%	trEPRinfo
%
% DESCRIPTION
%	This short program prints some basic information according the trEPR toolbox
%
% COMPATIBILITY
%	Tested to be fully compatible with GNU Octave - at least with Mac OS X
%	on 2007-06-27
%
% INPUT PARAMETERS
%	There are no input parameters at the moment.
%
% OUTPUT PARAMETERS
%	There are no input parameters at the moment.
%
% EXAMPLE
%	To get some basic information according the trEPR toolbox, simply typein
%
%		trEPRinfo
%
% SOURCE

function trEPRinfo

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPRinfo" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPRinfo" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in
	
	[ trEPRtoolboxRevisionNumber, trEPRtoolboxRevisionDate ] = trEPRtoolboxRevision;
	DisplayPlatform = platform;

	fprintf('================================================================================\n\n');
	fprintf(' trEPR, a Matlab toolbox for transient Electron Paramagnetic Resonance  \n\n');
	fprintf('   Release:          %s (%s) \n', trEPRtoolboxRevisionNumber, trEPRtoolboxRevisionDate);
	fprintf('   Directory:        %s \n',strrep(which('trEPRinfo'), 'm-files/trEPRinfo.m', ''));
	fprintf('   Matlab version:   %s \n',version);
	fprintf('   Platform:         %s \n\n',DisplayPlatform);
	fprintf('================================================================================\n\n');
	fprintf(' For latest information, please visit:\n\n');
	fprintf('   http://www2.till-biskup.de/projekte/matlab/trepr/\n\n');
	fprintf(' or write an email to <till@till-biskup.de>\n\n');
	fprintf('================================================================================\n\n');

%******
