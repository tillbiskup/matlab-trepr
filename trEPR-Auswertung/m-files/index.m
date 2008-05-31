% Copyright (C) 2004,2005 Peter J. Acklam, Till Biskup
% 
% This file ist free software.
% 
%****f* general.string_operations/index.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/09/28
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%
%	index = index(str, substr)
%
% DESCRIPTION
%
%	INDEX Return the position of the first occurence of the string SUBSTR
%	in the string STR, or 0 if no occurrence is found.
%
%	INDEX(STRING, SUBSTRING) returns the position of the first occurrence
%	of the string SUBSTRING in the string STRING, or 0 if no occurrence is found.
%
%	INDEX is a MATLAB version of the GNU Octave function with the same
%	name.
%
% INPUT
%	str
%		string in which to look for the string substr
%
%	substr
%		string that is looked for in the string string
%
% OUTPUT
%	index
%		scalar containing the position of the first occurence of the string substr
%		in the string str, or 0 if no occurrence is found
%
% EXAMPLE
%	To evaluate at which position of the string 'Hello world!' the string 'world'
%	starts just typein:
%
%		i = index('Hello world!', 'world')
%
%	The 'answer' would be '7' in that case.
%
% SOURCE

function index = index(str, substr)

	% fprintf ( '\nFUNCTION CALL: $Id$\n' );

	% check for right number of input and output parameters

	if nargin ~= 2
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help index" to get help.',nargin);
			% get error if function is called with other than
			% two input parameters
	end

	if nargout > 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help index" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% STR
	
	if ( ~isstr(str))

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help index" to get help.','str');
			% get error if function is called with the wrong format of the
			% input parameter 'str'
	
	% SUBSTR
	
	elseif ( ~isstr(substr))

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help index" to get help.','substr');
			% get error if function is called with the wrong format of the
			% input parameter 'substr'

	end	
   
	occurrences = findstr ( str, substr );

	if length ( occurrences ) > 0
	
		index = occurrences ( 1 );
		
	else
	
		index = 0;
		
	end
  
%******