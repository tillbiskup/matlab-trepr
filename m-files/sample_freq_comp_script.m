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
fprintf('\nThis file is intended to be used to test the frequency compensation of spectra\nrecorded with the fsc2 software.\nTherefore the user is first asked for a logfile file name...\n');


% First of all start logging

start_logging;


fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to test the frequency compensation of spectra\nrecorded with the fsc2 software.\nTherefore the user is asked for two input file names of fsc2 files.\nThese both spectra are drift compensated and afterwards plotted together\nfor manual frequency compensation.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');
fprintf('\nThe last versions of this file can be found at:\n\thttp://physik.fu-berlin.de/~biskup/\n');



% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

script_read_file;

filename_spectrum1 = filename;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );

% Evaluate drift and possible fits

script_drift;

  
drift_comp_data1 = drift_comp_data;
frequency1 = frequency;
field_params1 = field_params;
scope_params1 = scope_params;
time_params1 = time_params;
trigger_pos1 = time_params1(2);	% get trigger_pos out of time_params



% Then ask for a second file name to read and if file name is valid, read data

script_read_file;

filename_spectrum2 = filename;

% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );

% Evaluate drift and possible fits

script_drift;

  
drift_comp_data2 = drift_comp_data;
frequency2 = frequency;
field_params2 = field_params;
scope_params2 = scope_params;
time_params2 = time_params;
trigger_pos2 = time_params2(2);	% get trigger_pos out of time_params


script_compensate_frequency;


% Nice plot of the frequency compensated graphs with right axis tics and labels
							
[ spectrum1, max_index1 ] = B0_spectrum ( drift_comp_data1, 2 );
  
[ spectrum2, max_index2 ] = B0_spectrum ( drift_comp_data2, 2 );

figure;						% opens new graphic window

x1 = [ min([field_params1(1) field_params1(2)]) : 0.5 : max([field_params1(1) field_params1(2)]) ];
x2 = [ min([field_params2(1) field_params2(2)]) : 0.5 : max([field_params2(1) field_params2(2)]) ];

% to convert from G -> mT

x1 = x1 / 10;
x2 = x2 / 10;

hold on;
  
title('1D Plot of the frequency aligned B_0 spectra')
xlabel('B / mT');
ylabel('I');

plot(x1,spectrum1','-',x2,spectrum2','-',x1,zeros(1,length(x1)),'-')

legend( { strrep(get_file_basename(filename_spectrum1),'_','\_') , strrep(get_file_basename(filename_spectrum2),'_','\_') } )
  
hold off;
  
% At the very end stop logging

stop_logging;

% end of script