% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* global_scripts/platform.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/06/28
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	platform, operating system, kernel
%
% SYNOPSIS
%	platform
%
% DESCRIPTION
%	Display general platform dependend information
%
% COMPATIBILITY
%	This program seems to be compatible with GNU Octave 2.1.x.
%	It has currently been tested under Mac OS X 10.4 and GNU Linux only.
%
% INPUT PARAMETERS
%	Currently, there are no input parameters
%
% OUTPUT PARAMETERS
%	platform (optional)
%		string containing the platform specific information
%		such as operating system and version
%
% EXAMPLE
%	To simply get the information about the platform currently in use typein
%
%		platform
%
%	at the prompt. To use this information to plot it in a formatted context
%	you may use
%
%		platformString = platform;
%		fprintf('The platform we're running at is: %s', platformString);
%
% SOURCE

function platform = platform

%-%	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help platform" to get help.',nargin);

	end

	if ( nargout < 0 ) || ( nargout > 1 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help platform" to get help.',nargout);

	end


	% ...and here the 'real' stuff goes in

	% find platform OS
	
	if ( exist('matlabroot') )
	
		if ispc
		   platform = [system_dependent('getos'),' ',system_dependent('getwinsys')];
		elseif ( strcmp(computer, 'MAC') == 1 )
		    [fail, input] = unix('sw_vers');
		    
		    if ~fail
				platform = strrep(input, 'ProductName:', '');
				platform = strrep(platform, sprintf('\t'), '');
				platform = strrep(platform, sprintf('\n'), ' ');
				platform = strrep(platform, 'ProductVersion:', ' Version: ');
				platform = strrep(platform, 'BuildVersion:', 'Build: ');
			else
				platform = system_dependent('getos')
			end
		else    
			[fail, input] = unix('uname -srmo');

		    if ~fail
				platform = input;
			else
				platform = system_dependent('getos')
			end		   
		end

	else

		if ispc
		   platform = computer();
		elseif findstr('apple', computer)
		    [fail, input] = unix('sw_vers');
		    
		    if ~fail
				platform = strrep(input, 'ProductName:', '');
				platform = strrep(platform, sprintf('\t'), '');
				platform = strrep(platform, sprintf('\n'), ' ');
				platform = strrep(platform, 'ProductVersion:', ' Version: ');
				platform = strrep(platform, 'BuildVersion:', 'Build: ');
			else
				platform = computer();
			end
		else    
			[fail, input] = unix('uname -srmo');

		    if ~fail
				platform = input;
			else
				platform = computer();
			end		   
	   
		end

	end

	return

%******
