% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/11/15
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, baseline compensation
%
%	This file is a sample main script to test the baseline_compensation routine.
%

% ######################################################################
% BEGIN setting of global variables
%
% First of all set some global variables that control the general behaviour of the program.
% These variables are set in a way that you can set them by yourself before running this script.
% The script will test whether they are already defined and only if not will set them to some default
% value.
%
% In the moment the global variables are
%
%	DEBUGGING
%		boolean variable
%		if <> 0 then some additional debugging output is produced
%		this output starts with the words "DEBUGGING OUTPUT"
%
%	PLOTTING3D
%		boolean variable
%		if <> 0 then 3D plots of the spectra are plotted
%

if ( exist('DEBUGGING') == 0 )	
						% in the case the debug variable is not set...

	global DEBUGGING;
	DEBUGGING = 0;		% set DEBUGGING to ON
						% if debug <> 0 then additional DEBUGGING OUTPUT is printed

end;

if ( DEBUGGING )			% in the case the debug variable is set...

  fprintf('\nDEBUGGING ON\n');

end;

if ( exist('PLOTTING3D') == 0 )	
						% in the case the debug variable is not set...

	global PLOTTING3D;
	PLOTTING3D = 0;		% set PLOTTING3D to OFF
						% if PLOTTING3D <> 0 then additional 3D PLOTS are generated

end;

if ( PLOTTING3D )		% in the case the plot3d variable is set...

  fprintf('\n3D PLOTS ON\n');

end;

% END setting of global variables
% ######################################################################

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );
fprintf('\nThis file is intended to be used to test the manual baseline compensation of spectra\nrecorded with the fsc2 software.\nTherefore the user is first asked for a logfile file name...\n');


% First of all start logging

start_logging;


fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to test the manual baseline compensation of spectra\nrecorded with the fsc2 software.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');
fprintf('\nThe last versions of this file can be found at:\n\thttp://physik.fu-berlin.de/~biskup/\n');



% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

script_read_file;

filename_spectrum = filename;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );


% Find maximum signal amplitude

script_find_max_amplitude;


% Evaluate drift and possible fits

script_drift;


% Compensate baseline

script_compensate_baseline;


  
% At the very end stop logging

stop_logging;

% end of script