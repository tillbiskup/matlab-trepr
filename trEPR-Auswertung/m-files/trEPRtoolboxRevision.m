% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/trEPRtoolboxRevision.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/27
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	trEPR toolbox, revision, date
%
% SYNOPSIS
%	trEPRtoolboxRevision
%
% DESCRIPTION
%	Return the revision number and revision date of the current
%	trEPR toolbox revision.
%
%	This script is used to centrally manage the revision number and date
%	of the toolbox.
%
% INPUT PARAMETERS
%	Currently, there are no input parameters
%
% OUTPUT PARAMETERS
%	RevisionNumber (optional)
%		current revision number of the trEPR toolbox
%
%	RevisionDate (optional)
%		release date of the current revision of the trEPR toolbox
%
% EXAMPLE
%	You can simply typein the function name. This will produce a similar
%	output to the following:
%
%		>> trEPRtoolboxRevision
%		0.1.1 2007-04-24
%		>>
%
%	You can also call the function with one or two output parameters,
%	as follows
%
%		[ RevisionNumber ] = trEPRtoolboxRevision;
%		[ RevisionNumber, RevisionDate ] = trEPRtoolboxRevision;
%
% SOURCE

function [ varargout ] = trEPRtoolboxRevision

%	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPRtoolboxRevision" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 2 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPRtoolboxRevision" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in
	
	% This is the place to centrally manage the revision number and date.
	%
	% THIS VALUES SHOULD ONLY BE CHANGED BY THE OFFICIAL MAINTAINER OF THE TOOLBOX!
	%
	% If you have questions, call the trEPRinfo routine at the command prompt and
	% contact the maintainer via the email address given there.
	
	trEPRtoolboxRevisionNumber = '0.1.2';
	trEPRtoolboxRevisionDate = '2007-07-27';
	
	if (nargout == 1)
		% in case the function is called with one output parameter
	
		varargout{1} = trEPRtoolboxRevisionNumber;
		
	elseif (nargout == 2)
		% in case the function is called with two output parameters

		varargout{1} = trEPRtoolboxRevisionNumber;
		varargout{2} = trEPRtoolboxRevisionDate;
	
	else
		% in case the function is called without output parameters
	
		fprintf('%s %s\n',trEPRtoolboxRevisionNumber,trEPRtoolboxRevisionDate)
	
	end

%******
