% Copyright (C) 2006 Till Biskup
% 
% This file ist free software.
% 
%****f* user_routines/trEPR_compensate_timeslice.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2006 Till Biskup
%	This file is free software
% CREATION DATE
%	2006/04/21
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% KEYWORDS
%	transient EPR, time slices
%
% SYNOPSIS
%	ts = trEPR_compensate_timeslice
%
% DESCRIPTION
%	This function compensates a given time slice with its off-resonance signal.
%	Therefore it reads two fsc2 data files, one with the off-resonance time slice
%	and the other with the time slice at the maximum/minimum of the spectrum.
%
%	The former is used to compensate the background for the latter.
%
%	The user is asked interactively for the names of these two input files.
%
%	Both time slices are averaged before compensation. This is something that shoud
%	be changed in the future...
%
%	Additionally the time slice is saved together with the time axis values
%	with the trigger time t_0 set to zero (thus having negative time values for the
%	pretrigger signal).
%
%	The filename is created from the input filename of the signal time slice:
%	"<base-filename>-comp.<file-extension>".
%
% INPUT PARAMETERS
%	In the moment there are no input parameters
%
% OUTPUT PARAMETERS
%	ts
%		compensated time slice as row vector
%
% DEPENDS ON
%	The routine depends on several other routines from the trEPR toolbox:
%	* trEPR_read_fsc2_file
%	* pretrigger_offset
%	* get_file_basename
%	* get_file_extension
%	* ascii_save_timeslice
%
%	The availability of these routines is checked for at each call of this routine.
%
% TODO
%	Replace the averaging of both time slices with possibility to choose one single
%	spectrum of the time slice from the signal part of the spectrum or average over
%	the entire data set.
%
% SOURCE

function ts = trEPR_compensate_timeslice

	fprintf ( '\nFUNCTION CALL: $RCSfile$\n\t$Revision$, $Date$\n\n' );
	
	% check for right number of input and output parameters

	if ( nargin )
  
		error('\n\tThe function is called with the wrong number (%i) of input arguments.\n\tPlease use "help trEPR_snd" to get help.',nargin);
			% get error if function is called with 
			% input parameters
	end

	if ( nargout > 1 )
  
		error('\n\tThe function is called with the wrong number (%i) of output arguments.\n\tPlease use "help trEPR_snd" to get help.',nargout);
			% get error if function is called with more than
			% one output parameter. This condition makes it possible
			% to call the function without output arguments.
	end

	% check for the availability of the routines we depend on
	
	if ( exist('trEPR_read_fsc2_file.m') ~= 2 )

		error('\n\tThe function %s this function critically depends on is not available.\n', 'trEPR_read_fsc2_file');
	
	elseif  ( exist('pretrigger_offset.m') ~= 2 )
	
		error('\n\tThe function %s this function critically depends on is not available.\n', 'pretrigger_offset');
	
	elseif  ( exist('get_file_basename.m') ~= 2 )
	
		error('\n\tThe function %s this function critically depends on is not available.\n', 'get_file_basename');
	
	elseif  ( exist('get_file_extension.m') ~= 2 )
	
		error('\n\tThe function %s this function critically depends on is not available.\n', 'get_file_extension');
	
	elseif  ( exist('ascii_save_timeslice.m') ~= 2 )
	
		error('\n\tThe function %s this function critically depends on is not available.\n', 'ascii_save_timeslice');

	end
	
	
	% read in both files
	
	fprintf('\n------------------------------------------------------------\n');
	fprintf('\nOFF-RESONANCE TIME SLICE\n');
	
	[ off_resonance_ts,frequency,field_params,scope_params,time_params,or_filename,trigger_pos ] = trEPR_read_fsc2_file;
	
	fprintf('\n------------------------------------------------------------\n');
	fprintf('\nTIME SLICE AT SIGNAL MAXIMUM\n');
	
	[ signal_ts,frequency,field_params,scope_params,time_params,s_filename,trigger_pos ] = trEPR_read_fsc2_file;
	
	
	% offset compensation of both time slices
	
	off_resonance_ts = pretrigger_offset ( off_resonance_ts, trigger_pos );
	
	signal_ts = pretrigger_offset ( signal_ts, trigger_pos );
	
	
	% average both time slices
	
	% TODO:	This should be changed and replaced with
	% 		the possibility to choose one single spectrum of the
	% 		time slice from the signal part of the spectrum
	% 		or average over the entire data set.
	
	off_resonance_ts = mean ( off_resonance_ts );
	
	signal_ts = mean ( signal_ts );
	
	
	% compensate signal time slice
	
	comp_signal_ts = signal_ts - off_resonance_ts;
	
	
	% save compensated signal time slice together with B_0 axis values to file
	
	out_filename = [ get_file_basename( s_filename ) '-comp.' get_file_extension( s_filename ) ];
	
	ascii_save_timeslice ( out_filename, comp_signal_ts, field_params, time_params, frequency );
	
	fprintf('\nThe compensated time slice has been saved to the file %s\n', out_filename);
	
	
	ts = comp_signal_ts;
	
%******