% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* general.file_handling/get_file_path.m
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
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	MATLAB(R), GNU Octave
%
% SYNOPSIS
%	file_path = get_file_path ( filename )
%
% DESCRIPTION
%
%	GET_FILE_PATH gets the path out of a complete filename
%	with path and extension and returns it as string.
%
%	If there is no file path then the function will return
%	the empty string ''.
%
% EXAMPLE
%	To get the file path out of a complete filename with path typein
%
%		file_path = get_file_path ( filename )
%
% SEE ALSO
%	get_file_basename, get_file_extension
%
% SOURCE

function file_path = get_file_path ( filename )
	
	% fprintf ( '\nFUNCTION CALL: $Id$\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help get_file_path" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if ( nargout ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help get_file_path" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter.
	end

	% check for right format of input parameter
	
	if ~isstr( filename )
  
		error('\n\tThe function is called with the wrong kind of input arguments.\n\tPlease use "help get_file_path" to get help.',nargin);
			% get error if function is called with other than
			% a string input parameter
	end

  if ( ( length(findstr(filename,'/')) > 0 ) )
  						% in the case that a '/' contained in the string 'filename'

	file_path = filename (1 : (max(findstr(filename,'/'))));
						% get file path (with ending slash) from read filename
	
  else
  
	file_path = '';
						% set the file_path variable to the empty string

  end

	

%*******