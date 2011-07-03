% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* general.file_handling/get_file_basename.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/31
% VERSION
%	$Revision: 239 $
% MODIFICATION DATE
%	$Date: 2006-06-07 17:11:14 +0100 (Mi, 07 Jun 2006) $
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%	file_basename = get_file_basename ( filename )
%
% DESCRIPTION
%
%	GET_FILE_BASENAME gets the file basename out of a complete filename
%	with path and extension and returns it as string.
%
% EXAMPLE
%	To get the file basename out of a complete filename with path typein
%
%		file_basename = get_file_basename ( filename )
%
% SEE ALSO
%	get_file_path, get_file_extension
%
% SOURCE

function file_basename = get_file_basename ( filename )

	% fprintf ( '\nFUNCTION CALL: $Id: get_file_basename.m 239 2006-06-07 16:11:14Z web8 $\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help get_file_basename" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if ( nargout ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help get_file_basename" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter.
	end

	% check for right format of input parameter
	
	if ~isstr( filename )
  
		error('\n\tThe function is called with the wrong kind of input arguments.\n\tPlease use "help get_file_basename" to get help.',nargin);
			% get error if function is called with other than
			% a string input parameter
	end

	if ( ( length(findstr(filename,'/')) > 0 ) )
  						% in the case that a '/' contained in the string 'filename'

		file_basename = filename ((max(findstr(filename,'/'))+1) : (max(findstr(filename,'.'))-1));
						% get base filename (without extension) from read filename
	
	else
  
		file_basename = filename ( 1 : (max(findstr(filename,'.'))-1));
						% get base filename (without extension) from read filename
						% suggesting that the file_basename starts at position 1 of
						% the string 'filename'

	end


%*******