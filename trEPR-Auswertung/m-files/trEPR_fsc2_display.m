% Copyright (C) 2007 Till Biskup
%
% This file ist free software.
%
%****f* GUI/trEPR_fsc2_display.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2007 Till Biskup
%	This file is free software
% CREATION DATE
%	2007/02/21
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	fsc2, 2D display, 1D slices, B_0 slice, time slice
%
% SYNOPSIS
%	trEPR_fsc2_display
%
% DESCRIPTION
%	This function provides a fsc2-like display with the possibility
%	to select time and B_0 slices. It makes use of the MATLAB(TM)
%	GUI possibilities.
%
%	This function appeared in version > 0.1.0 of the trEPR toolbox.
%
% INPUT PARAMETERS
%	no input parameters yet
%
% OUTPUT PARAMETERS
%	no output parameters yet
%
% DEPENDS ON
%	trEPR_read_fsc2_file.m
%	GUI_fsc2_display.m
%
% EXAMPLE
%	To display the 2D transient EPR data measured with fsc2, simply typein
%
%		trEPR_fsc2_display
%
%	and follow the instructions.
%
% SOURCE

function trEPR_fsc2_display

	fprintf('\nFUNCTION CALL: $Id$\n\n');

	% check for the right number of input and output parameters

	if ( nargin ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_fsc2_display" to get help.',nargin);

	end

	if ( nargout ~= 0 )

		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_fsc2_display" to get help.',nargout);

	end


	% test by which program we are called
	% this is because the function makes heavy use of MATLAB(TM) specific functionality
	
	if (exist('program') == 0)
		% if the variable "program" is not set, that means the routine isn't called
		% yet...

		if exist('discriminate_matlab_octave')
			% let's check whether the routine performing the discrimination
			% is available...

		    program = discriminate_matlab_octave;
	    
		else
			% that means if the variable "program" isn't set yet and the routine
			% performing the discrimination isn't available...
	
			fprintf('\nSorry, the function to distinguish between Matlab(TM) and GNU Octave cannot be found.\nThis function will behave as if it is called within MATLAB(TM)...\nBe aware: In the case that is not true you can run into problems!');
		
			program = 'Matlab';
			
			% set variable to default value
	
		end;
	
	end;


	if program == 'Octave'	% if we're called by GNU Octave (as determined above)

		error('Sorry, but this routine cannot be used with GNU Octave at the moment...');
		
		% If we're called by GNU Octave any further processing will be aborted due to
		% the problems described above.
		
	end;

	% check for the availability of the routines we depend on

	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'trEPR_read_fsc2_file');


	elseif ( exist('GUI_fsc2_display.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'GUI_fsc2_display');

	end
	

	% ...and here the 'real' stuff goes in

	[ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file;
	
	titlestring = filename;
	
	GUI_fsc2_display (data, field_params, time_params, titlestring);

%******
