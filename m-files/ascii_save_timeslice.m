% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****m* core_routines/ascii_save_timeslice.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/10
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, fsc2, ASCII save data
%
% SYNOPSIS
%	ascii_save_timeslice ( filename, timeslice, field_params, time_params, [frequency] )
%
% DESCRIPTION
%	This function saves an 1D timeslice as ASCII file with leading commentaries
%
% SOURCE

function ascii_save_timeslice ( filename, timeslice, field_params, time_params, varargin )

	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n' );
	
	% check for right number of input and output parameters

	if ( nargin < 4 ) || ( nargin > 5)
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help ascii_save_timeslice" to get help.',nargin);
			% get error if function is called with other than
			% four input parameters
	end
	
	if nargin == 5
	
		frequency = varargin{1};
	
	end
	
	
	% open file given by filename for write access
	
	fid=0;				% set file identifier to standard value
	
	while fid < 1 		% while file not opened
	
		[fid,message] = fopen(filename, 'wt');
						% try to open file 'filename' and return fid and message
		if fid == -1		% if there are any errors while trying to open the file
		
			error('\n\tFile %s could not be opened for write:\n\t%s', filename, message);
						% display the message from fopen
						
		end				% end "if fid"
		
	end					% end while loop

	% write header

	comment_char = '%';

	fprintf(fid, '%s This file has been written by the routine $RCSfile$, $Revision$ from $Date$\n', comment_char);
	fprintf(fid, '%s\n', comment_char);
	fprintf(fid, '%s Field parameters were:\n%s\tstart field: %i G\n%s\tstop field:  %i G\n%s\tstep width:   %2.1f G\n', comment_char,comment_char,field_params(1),comment_char,field_params(2),comment_char,field_params(3));
	fprintf(fid, '%s\n', comment_char);
	fprintf(fid, '%s Time parameters were:\n%s\tnumber of points: %i\n%s\ttrigger position: %i\n%s\tlength:           %i microseconds\n', comment_char,comment_char,time_params(1),comment_char,time_params(2),comment_char,time_params(3));
	fprintf(fid, '%s\n', comment_char);
	
	if exist('frequency') == 1

		fprintf(fid, '%s Frequency was:\n%s\t%7.5f GHz\n', comment_char, comment_char, frequency);
		fprintf(fid, '%s\n', comment_char);
	
	end
	
	fprintf(fid, '%s Description of the data:\n', comment_char);
	fprintf(fid, '%s\t1st column: time in microseconds\n', comment_char);
	fprintf(fid, '%s\t2nd column: signal intensity in mV\n', comment_char);
	fprintf(fid, '%s\n', comment_char);
	

	% write data
	
	
	time = [ -time_params(3)/time_params(1)*time_params(2) + time_params(3)/time_params(1) : time_params(3)/time_params(1) : time_params(3)-time_params(3)/time_params(1)*time_params(2) ];
	
	j = 1;
	
	while (j<=length(timeslice))
	
		fprintf(fid, '%5.1f\t%14.12f\n',time(j),timeslice(j));
		j = j + 1;
		
	end;
	
	% save close file

	while fid > 2
		% the fids 0, 1 and 2 are reserved for special purposes (input, output, error)
		% that's why every other file identifier (file handle) has a number > 2
	
		% try to close the file
		status = fclose(fid);

		% test whether the closing was successful
		if status == -1
			% if there are any errors while trying to close the file
		
			error('\n\tFile %s could not be closed:\n\t%s', filename, status);
						% display the message from fclose
						
		elseif status == 0
		
			% set file identifier to exit while loop
			fid = -1;
						
		end				% end "if fid"
		
	end					% end while loop
	

%*******