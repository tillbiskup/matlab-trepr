% Copyright (C) 2004,2005 Peter J. Acklam, Till Biskup
% 
% This file ist free software.
% 
%****f* general.string_operations/substr.m
%
% AUTHOR
%	Peter J. Acklam <pjacklam@online.no>
%	URL: http://home.online.no/~pjacklam
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2004,2005 Peter J. Acklam, Till Biskup
%	This file is free software
% CREATION DATE
%	2004/02/21
% VERSION
%	$Revision: 353 $
% MODIFICATION DATE
%	$Date: 2007-01-31 17:41:15 +0000 (Mi, 31 Jan 2007) $
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%	outstr = substr(str, offset, len, repl)
%
% DESCRIPTION
%
%	SUBSTR Extract a substring out of a string.
%
%	SUBSTR(STRING, OFFSET, LENGTH) extracts a substring out of STRING with
%	given LENGTH starting at the given OFFSET.  First character is at offset 0.
%	If OFFSET is negative, starts that far from the end of the string.  If
%	LENGTH is omitted, returns everything to the end of the string.  If LENGTH
%	is negative, removes that many characters from the end of the string.
%
%	SUBSTR(STRING, OFFSET, LENGTH, REPLACEMENT) will not return the substring
%	as specified by STRING, OFFSET, and LENGTH (see above) but rather replace
%	it by REPLACEMENT and return the result.
%
% INPUT
%	str
%		string from which the string outstr is extracted depending on the parameters
%		offset, len, and repl
%
%	offset
%		scalar containing the position in the string str where to start with
%		extracting the string outstr
%
%	len (OPTIONAL)
%		scalar containing the number of chars that should be extracted from the
%		string str starting at the position offset.
%
%		If len is omitted, substr returns everything to the end of the string.
%
%		If len is negative, substrremoves that many characters from the end 
%		of the string str.
%
%	repl (OPTIONAL)
%		string containing a replacement for the part of the string str defined by
%		the parameters offset and len.
%
% OUTPUT
%	outstr
%		string containing a part of the string str depending on the parameters
%		offset, len, and repl
%
% EXAMPLE
%
%		Get first character:				substr(string,  0, 1)
%		Get last character:				substr(string, -1, 1)
%		Remove first character:			substr(string,  1)
%		Remove last character:			substr(string,  0, -1)
%		Remove first and last character:  substr(string,  1, -1)
%
%	SUBSTR is a MATLAB version of the Perl operator with the same name.
%	However, unlike Perl's SUBSTR, no warning is produced if the substring is
%	totally outside the string.
%
% SOURCE

function outstr = substr(str, offset, len, repl)

	% fprintf ( '\nFUNCTION CALL: $Id: substr.m 353 2007-01-31 17:41:15Z web8 $\n' );

	% check for right number of input and output parameters

	if ( ( nargin < 2 ) || ( nargin > 4 ) )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help substr" to get help.',nargin);
			% get error if function is called with less than
			% two or more than four input parameters
	end

	if nargout > 1
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help substr" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter
	end

	% check for correct format of the input parameters
	
	% STR
	
	if ( ~isstr(str))

		error('\n\tThe function is called with the wrong format for the input argument %s.\n\tPlease use "help index" to get help.','str');
			% get error if function is called with the wrong format of the
			% input parameter 'str'
			
	end
	
	n = length(str);

	% Get lower index.
	lb = offset + 0;			% offset from beginning of string %% TB: 'offset + 1' -> 'offset + 0'
	if offset < 0
		lb = lb + n;			% offset from end of string
	end
	lb = max(lb, 1);

	% Get upper index.
	if nargin == 2			% SUBSTR(STR, OFFSET)
		ub = n;
	elseif nargin > 2		% SUBSTR(STR, OFFSET, LEN)
		if len >= 0
			ub = lb + len - 1;
		else
			ub = n + len;
		end
		ub = min(ub, n);
	end

	% Extract or replace substring.
	if nargin < 4
		outstr = str(lb : ub);		% extract substring
	else
		outstr = [str(1:lb-1) repl str(ub+1:end)];	 % replace substring
	end

%*******