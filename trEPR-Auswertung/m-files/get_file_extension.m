% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* general.file_handling/get_file_extension.m
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
%	file_extension = get_file_extension ( filename )
%
% DESCRIPTION
%
%	GET_FILE_EXTENSION gets the file extension out of a complete filename
%	with path and extension and returns it as string.
%
% EXAMPLE
%	To get the file extension out of a complete filename with path typein
%
%		file_extension = get_file_extension ( filename )
%
% SEE ALSO
%	get_file_basename, get_file_path
%
% SOURCE

function file_extension = get_file_extension ( filename )
	
	% fprintf ( '\nFUNCTION CALL: $Id$\n' );
	
	% check for right number of input and output parameters

	if ( nargin ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help get_file_extension" to get help.',nargin);
			% get error if function is called with other than
			% one input parameter
	end

	if ( nargout ~= 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help get_file_extension" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter.
	end

	% check for right format of input parameter
	
	if ~isstr( filename )
  
		error('\n\tThe function is called with the wrong kind of input arguments.\n\tPlease use "help get_file_extension" to get help.',nargin);
			% get error if function is called with other than
			% a string input parameter
	end

	file_extension = filename ( (max(findstr(filename,'.'))+1) : length(filename) );
						% get file extension from read filename (without leading dot)
	

%*******