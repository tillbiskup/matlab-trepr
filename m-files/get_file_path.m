% Copyright (C) 2004,2005 Peter J. Acklam, Till Biskup
% 
% This file ist free software.
% 
%****f* auxilliary_routines/get_file_basename.m
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
%
% SOURCE

function file_path = get_file_path ( filename )


  if ( ( length(findstr(filename,'/')) > 0 ) )
  						% in the case that a '/' contained in the string 'filename'

	file_path = filename (1 : (max(findstr(filename,'/'))));
						% get file path (with ending slash) from read filename
	
  else
  
	file_path = ''
						% set the file_path variable to the empty string

  end

	

%*******