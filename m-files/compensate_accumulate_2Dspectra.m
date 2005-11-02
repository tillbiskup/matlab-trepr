% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/26
% Derived from:		sample_accumulation_script.m
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, accumulate spectra
%
%	This file is a sample main script that uses all the implemented functions
%	for data analysis of trEPR data recorded with the program fsc2.
%	Therefore it depends on these functions that reside in the m-files in the 
%	same directory as this script.
%
%	The file serves as an example for own scripts.
%
%	The big difference tho the script 'sample_script' is that here the main part
%	that compensates for offset and drift resides in a loop and thus the program
%	allows to read several fsc2 files and accumulate the spectra

tic;						% set starting point for calculation of used time, just for fun...

% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

fprintf( '\nThis is the file $RCSfile$, $Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate and accumulate 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\nThe whole compensation process is being logged in a file that''s name he user is\nasked to provide at the very beginning of the processing of this script.\n');


% First of all start logging

start_logging;


% Then print some nice message

dateandtime = [datestr(now, 31), ' @ ', computer];

disp ( dateandtime )	% print current date and time and system

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate and accumulate 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');
fprintf('\nThe last versions of this file can be found at:\n\thttp://physik.fu-berlin.de/~biskup/\n');

% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


exit_main_loop = 1;				% set exit condition for while loop

while exit_main_loop > 0			% main while loop
								% responsible for the possibility to accumulate
								% more than one spectrum after compensation
								% for pretrigger offset and drift

% Next ask for a file name to read and if file name is valid, read data

script_read_file;

% Plot raw data

field_boundaries = [ field_params(1) field_params(2) ];

[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

fprintf('\nPlot raw data...\n')

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

  gsplot ( data' );			% make simple 3D plot of the raw data

else								% otherwise we assume that we're called by MATLAB(R)

  mesh ( data );				% make simple 3D plot of the raw data

  title('Raw data');

end


% Give user the possibility to cut off the spectrum at its start or end
% by deleting a variable amount of time slices

script_cut_off;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );



% Evaluate drift and possible fits

fprintf('\nEvaluate drift and possible fits...\n');
fprintf('\nChoose between the display modes...\n');

drift_display = menu ( 'DRIFT COMPENSATION: Which display mode should be used?', 'Show drift and fit curve', 'Show B_0 spectrum at signal maximum' );

if ( drift_display == 1)

  fprintf('\tShow drift and fit curve chosen\n');
  
  script_drift;

else

  fprintf('\tShow B_0 spectrum at signal maximum chosen\n');

  script_drift_show_compensated;

end


% Save last dataset to file

outputfilename = [ get_file_path(filename) get_file_basename(filename) '-comp.' get_file_extension(filename) ];
								% the output filename consists of the path of the input file,
								% the basename of the input file with appended '-comp'
								% and the extension of the input file (normally '.dat')

fprintf('\nSaving ASCII data to the file %s...\n', outputfilename)
								% Telling the user what's going to happen

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'drift_comp_data');
								% save data to ascii file

else								% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'drift_comp_data', '-ascii');
								% save data to ascii file in a MATLAB(R) compatible way
								% (silly MATLAB behaviour - to accept the Octave variant of
								% calling but neither saving nor complaining all about...)

end								% end of "if program" clause



if exit_main_loop > 1				% if the exit condition for the main while loop
								% set at the beginning and increased at the end of every
								% pass of the loop is larger than one (that means that the
								% while loop is passed for more than one time til here)
  

  [ drift_comp_data, matrix1, field_params ] = adjust_matrix_size ( drift_comp_data, field_params, time_params, matrix1, old_field_params, old_time_params );
  						% Adjust sizes of matrices: matrix from former pass of loop
  						% and matrix just read from the new fsc2 file


  % frequency compensation

  drift_comp_data1 = drift_comp_data;
  drift_comp_data2 = matrix1;
  								% set the matrices according to the necessary settings for the
  								% script file script_compensate_frequency.m
  field_params1 = field_params;
  field_params2 = old_field_params;
  								
  script_compensate_frequency;



  % After plotting the overlay of both B_0 spectra
  % ask the user whether he really wants to proceed with accumulation...

  really_accumulate = menu( 'Do you really want to accumulate?', 'Yes, accumulate!', 'No, continue with old spectrum', 'No, continue with new spectrum' );

  if ( really_accumulate == 1 )
  						% if the user still wants to accumulate

	fprintf('\nYou decided to accumulate both spectra.\n')

    script_accumulate;
    						% call part of the script that does the accumulation
    
  elseif ( really_accumulate == 2 )
  						% if the user wants to abort accumulation and
  						% wants to proceed with the old spectrum
  						
	fprintf('\nYou decided not to accumulate\n and to revert to the old spectrum.\n')
  	drift_comp_data = matrix1;
  						% set the old matrix to the actual matrix 
  						
  else
  						% if the user wants to abort accumulation and
  						% wants to proceed with the new spectrum 
  						% just compensated
  						
	fprintf('\nYou decided not to accumulate\n and to continue with the just compensated spectrum.\n')
  
  end
  
  
else 					% if first pass of main loop

  % print 2D spectrum
  
  figure;						% opens new graphic window
  
  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('accumulated and compensated data');
	gsplot ( drift_comp_data' );
								% make simple 3D plot of the offset compensated data

  else							% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', drift_comp_data );
								% make simple 3D plot of the offset compensated data
	title('accumulated and compensated data');

  end

  % print B_0 spectrum

  figure;

  [spectrum,max_x] = B0_spectrum(drift_comp_data,2);
 
  x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
  
  % to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT
  x = x / 10;  
  
  plot(x,spectrum,x,zeros(1,length(x)));


end;						% end "if exit_main_loop" clause


exit_answer = menu ( 'What do you want to do now?', 'Read new file (and accumulate data)', 'Exit program');
						% make menu that lets the user choose which drift compensation
						% method he wants to use
						
if exit_answer == 1

  exit_main_loop = exit_main_loop + 1
  
  matrix1 = drift_comp_data;
  						% save compensated data to matrix
  old_field_params = field_params;
  old_time_params = time_params;
  						% save parameters for comparison with the next spectrum
  						
  clear data drift* filename method* offset* pv* trigger_pos X Y;
						% clear old variables that are not used any more

elseif exit_answer == 2

  exit_main_loop = 0;

end						% end of "if exit_answer" clause

end						% end of main while loop

total_time_used = toc;
fprintf ('\nThe total time used is %i seconds\n\n', total_time_used);
						% print total time used;

% At the very end stop logging...

stop_logging;

% end of script