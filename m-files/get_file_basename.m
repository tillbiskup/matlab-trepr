% Copyright (C) 2005 Till Biskup
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
%	file_basename = get_file_basename ( filename )
%
% DESCRIPTION
%
%	GET_FILE_BASENAME gets the file basename out of a complete filename
%	with path and extension and returns it as string.
%
%
% SOURCE

function file_basename = get_file_basename ( filename )

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