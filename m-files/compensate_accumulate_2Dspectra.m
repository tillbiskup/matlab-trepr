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

fprintf( '\nThis is the file $RCSfile$, $Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate and accumulate 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');


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

script_drift;

drift2_comp_data = drift_comp_data;


% Save last dataset to file

outputfilename = [ filename, '.out'];
								% the output filename consists of the filename of the input file
								% with appended extension ".out"

fprintf('\nSaving ASCII data to the file %s...\n', outputfilename)
								% Telling the user what's going to happen

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'drift2_comp_data');
								% save data to ascii file

else								% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'drift2_comp_data', '-ascii');
								% save data to ascii file in a MATLAB(R) compatible way
								% (silly MATLAB behaviour - to accept the Octave variant of
								% calling but neither saving nor complaining all about...)

end								% end of "if program" clause



if exit_main_loop > 1				% if the exit condition for the main while loop
								% set at the beginning and increased at the end of every
								% pass of the loop is larger than one (that means that the
								% while loop is passed for more than one time til here)
  

  [ drift2_comp_data, matrix1, field_params ] = adjust_matrix_size ( drift2_comp_data, field_params, time_params, matrix1, old_field_params, old_time_params );
  						% Adjust sizes of matrices: matrix from former pass of loop
  						% and matrix just read from the new fsc2 file



  fprintf('\nPrinting B_0 spectra for frequency compensation...\n')
								% Telling the user what's going to happen
								
  [ spectrum1, max_index1 ] = B0_spectrum ( matrix1, 2 );
  
  [ spectrum2, max_index2 ] = B0_spectrum ( drift2_comp_data, 2 );
  
  figure;						% opens new graphic window
  
  x = [ 1 : 1 : size( matrix1( :, max_index1 )) ];
  
  plot(x,spectrum1','-',x,spectrum2','-',x,zeros(1,length(x)),'-')


  pause;


  fprintf('\nAccumulate measurements...\n')
								% Telling the user what's going to happen

  acc_meas = accumulate_measurements ( drift2_comp_data, matrix1 );
  								% accumulate the measurements compensated until here
  
  figure;						% opens new graphic window
  
  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('accumulated and compensated data');
	gsplot ( acc_meas' );
								% make simple 3D plot of the offset compensated data

  else							% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', acc_meas );
								% make simple 3D plot of the offset compensated data
	title('accumulated and compensated data');

  end
  
  % Save accumulated measurements

  user_provided_filename = input ( 'Please enter a filename for the ASCII file for saving the accumulated data\n(if empty, the last input filename will be used with .acc appended): ', 's' );

  if length( user_provided_filename ) > 0	
						% If the user provided a filename

	outputfilename = user_provided_filename;
	
	fprintf ( '\nFile %s will be used to store the ASCII data of the accumulated data...\n\n', outputfilename );
  
  else					% In case the user didn't provide a filename

	outputfilename = [ filename, '.acc'];
						% the output filename consists of the filename of the input file
						% with appended extension ".acc"

	graphicsoutputfilename = [ filename, '.eps'];
						% the output filename consists of the filename of the input file
						% with appended extension ".eps"

	fprintf ( '\nFile %s will be used to store the ASCII data of the accumulated data...\n\n', outputfilename );

  end

  fprintf('\nSaving ASCII data to the file %s...\n', outputfilename)
						% Telling the user what's going to happen

  if program == 'Octave'	% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'acc_meas');
						% save data to ascii file

  else					% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'acc_meas', '-ascii');
						% save data to ascii file in a MATLAB(R) compatible way
						% (silly MATLAB behaviour - to accept the Octave variant of
						% calling but neither saving nor complaining all about...)

%	saveas(gcf,graphicsoutputfilename,eps);
						% save last graphics window content as eps file
						% the handle 'gcf' refers to the actual graphics window

  end					% end of "if program" clause
  

  % print B_0 spectrum of accumulated data

  figure;

  [spectrum,max_x] = B0_spectrum(acc_meas,2);
 
  x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
  
  plot(x,spectrum,'-',x,zeros(1,length(x)));

  
else 					% if first pass of main loop

  % print 2D spectrum
  
  figure;						% opens new graphic window
  
  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('accumulated and compensated data');
	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

  else							% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', drift2_comp_data );
								% make simple 3D plot of the offset compensated data
	title('accumulated and compensated data');

  end

  % print B_0 spectrum

  figure;

  [spectrum,max_x] = B0_spectrum(drift2_comp_data,2);
 
  x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
  
  plot(x,spectrum,'-',x,zeros(1,length(x)));


end;						% end "if exit_main_loop" clause


exit_answer = menu ( 'What do you want to do now?', 'Read new file (and accumulate data)', 'Exit program');
						% make menu that lets the user choose which drift compensation
						% method he wants to use
						
if exit_answer == 1

  exit_main_loop = exit_main_loop + 1
  
  matrix1 = drift2_comp_data;
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