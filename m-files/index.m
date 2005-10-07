% Copyright (C) 2004,2005 Peter J. Acklam, Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/index.m
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
% SOURCE

function index = index(str, substr)

  % Check number of input arguments.
  error(nargchk(2, 2, nargin));
   
  occurrences = findstr ( str, substr );

  if length ( occurrences ) > 0
	index = occurrences ( 1 );
  else
    index = 0;
  end
  
%******