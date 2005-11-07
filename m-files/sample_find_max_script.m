% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, frequency compensation
%
%	This file is a sample main script to test the frequency_compensation routine.
%

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );
fprintf('\nThis file is intended to be used to test the manual evaluation of the signal maximum of spectra\nrecorded with the fsc2 software.\nTherefore the user is first asked for a logfile file name...\n');


% First of all start logging

start_logging;


fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to test the manual evaluation of the signal maximum of spectra\nrecorded with the fsc2 software.\n');
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

%script_drift;


  
% At the very end stop logging

stop_logging;

% end of script