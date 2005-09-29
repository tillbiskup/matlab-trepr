function index = index(str, substr)
%INDEX Return the position of the first occurence of the string SUBSTR
%in the string STR, or 0 if no occurrence is found.
%
%	INDEX(STRING, SUBSTRING) returns the position of the first occurrence
%	of the string SUBSTRING in the string STRING, or 0 if no occurrence is found.
%
%	SUBSTR is a MATLAB version of the GNU Octave function with the same
%	name.

%	Author:				Till Biskup <till.biskup@physik.fu-berlin.de>
%	Maintainer:			Till Biskup <till.biskup@physik.fu-berlin.de>
%	Created:				2005/09/28
%	Version:				$Revision$
%	Last Modification:	$Date$

  % Check number of input arguments.
  error(nargchk(2, 2, nargin));
   
  occurrences = findstr ( str, substr );

  if length ( occurrences ) > 0
	index = occurrences ( 1 );
  else
    index = 0;
  end