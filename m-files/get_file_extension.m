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
%	file_extension = get_file_extension ( filename )
%
% DESCRIPTION
%
%	GET_FILE_EXTENSION gets the file extension out of a complete filename
%	with path and extension and returns it as string.
%
%
% SOURCE

function file_extension = get_file_extension ( filename )

	file_extension = filename ( (max(findstr(filename,'.'))+1) : length(filename) );
						% get file extension from read filename (without leading dot)
	

%*******