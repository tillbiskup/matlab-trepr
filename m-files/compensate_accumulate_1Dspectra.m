% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/11/18
% Derived from:		compensate_accumulate_2Dspectra.m
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
%	The big difference to the script 'accumulate_compensate_2Dspectra' is that
%	here only the 1D B_0 spectrum is worked on instead of the whole 2D data set
%
%
%	The script consists of several parts each of which accounts for a special
%	task in the compensation of the raw data.
%
%	In addition there are some "administrational" tasks that the script will do.
%
%	The parts in the order of their appearance:
%
%	NOTE: Tasks in brackets are optional, the user is asked whether to perform or not
%
%	0.	Set global variables
%
%	1.	Start logging
%
%	2.	Evaluate the calling program - MATLAB(R) vs. GNU Octave
%
%	3.	Read file
%
%	4.	[Cut spectrum]
%
%	5.	Compensate pretrigger offset
%
%	6.	Evaluate maximum signal amplitude according to t
%
%	7.	Evaluate drift
%
%	8.	Compensate baseline
%
%	9.	Save data
%
%	10.	Frequency compensation
%
%	11.	[Accumulation]
%
%	12.	Stop logging
%
%	Tasks 3 to 10 reside in one main loop that is processed until the user decides to stop it.
%	Tasks 9 and 10 are only done beginning with the second pass of the main loop.
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
%		cause the scripts that are called by this script
%		can also work on the whole 2D spectra this variable has to
%		be defined and set.
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

  fprintf('\PLOTTING3D ON\n');

end;

% END setting of global variables
% ######################################################################



tic;						% set starting point for calculation of used time, just for fun...


% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

fprintf( '\nThis is the file $RCSfile$, $Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate and accumulate 2D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\nThe whole compensation process is being logged in a file that''s name he user is\nasked to provide at the very beginning of the processing of this script.\n');

% First of all start logging

logfilename = start_logging;


% Then print some nice message

dateandtime = [datestr(now, 31), ' @ ', computer];

disp ( dateandtime )	% print current date and time and system

fprintf('\n---------------------------------------------------------------------------\n');
fprintf('\nGENERAL DESCRIPTION OF THE PROGRAM\n')

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate and accumulate 2D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\nWith this program only the 1D B_0 plots are compensated and saved.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');
fprintf('\nThe last versions of this file along with some documentation can be found at:\n\thttp://physik.fu-berlin.de/~biskup/\n');
fprintf('\nNOTE:\tThe revision of any routine and script called is logged in this file.\n\tTherefore it is possible to track back any errors or problems with\n\tone specific revision of one part of the program thanks to the\n\trevision control system.\n');

fprintf('\nThe following tasks are performed by the program and repeated for every spectrum\nthe user provides. (Tasks in brackets depend on whether the user\nchooses to perform them):\n');
fprintf('\n\t1. [Cut spectrum]');
fprintf('\n\t2. Compensate pretrigger offset');
fprintf('\n\t3. Evaluate maximum signal amplitude according to t');
fprintf('\n\t4. Evaluate drift');
fprintf('\n\t5. Compensate baseline');
fprintf('\n\t6. Save data');
fprintf('\n\t7. Frequency compensation');
fprintf('\n\t8. [Accumulation]\n');

fprintf('\n---------------------------------------------------------------------------\n');

% Find out whether we are called by MATLAB(R) or GNU Octave


[ program, prog_version ] = discriminate_matlab_octave;


exit_main_loop = 1;				% set exit condition for while loop

num_accumulated_spectra = 1;		% set number of accumulated spectra to 1 (default)

filenames_accumulated = '';
filenames_not_accumulated = '';

while exit_main_loop > 0			% main while loop
								% responsible for the possibility to accumulate
								% more than one spectrum after compensation
								% for pretrigger offset and drift

% Next ask for a file name to read and if file name is valid, read data

script_read_file;

% Plot raw data

field_boundaries = [ field_params(1) field_params(2) ];

if ( PLOTTING3D )		% in the case the plot3d variable is set...

  fprintf('\nPlot raw data...\n')

  [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

  if program == 'Octave'
						% if we're called by GNU Octave (as determined above)

    gsplot ( data' );	
						% make simple 3D plot of the raw data

  else					% otherwise we assume that we're called by MATLAB(R)

    mesh ( data );		% make simple 3D plot of the raw data

    title('Raw data');

  end

end;

% Give user the possibility to cut off the spectrum at its start or end
% by deleting a variable amount of time slices

script_cut_off;


% Next compensate pretrigger offset

fprintf('\n---------------------------------------------------------------------------\n');
fprintf( '\nCompensate pretrigger offset\n' );

offset_comp_data = pretrigger_offset ( data, trigger_pos );


% Give user the possibility to manually evaluate the t value at which the signal
% amplitude of the B_0 spectrum is maximal

script_find_max_amplitude;



% Evaluate drift and possible fits

fprintf('\n---------------------------------------------------------------------------\n');
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


% Compensate baseline

script_compensate_baseline;
						% The variable that contains the baseline compensated
						% B_0 spectrum is called "compensated_spectrum"

% Save last dataset to file

fprintf('\n---------------------------------------------------------------------------\n');
fprintf('\nSave compensated data to file\n');

outputfilename = [ get_file_path(filename) get_file_basename(filename) '-comp.' get_file_extension(filename) ];
								% the output filename consists of the path of the input file,
								% the basename of the input file with appended '-comp'
								% and the extension of the input file (normally '.dat')

fprintf('\nSaving ASCII data to the file\n\t%s\n', outputfilename)
								% Telling the user what's going to happen

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'compensated_spectrum');
								% save data to ascii file

else								% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'compensated_spectrum', '-ascii');
								% save data to ascii file in a MATLAB(R) compatible way
								% (silly MATLAB behaviour - to accept the Octave variant of
								% calling but neither saving nor complaining all about...)

end								% end of "if program" clause



if exit_main_loop > 1				% if the exit condition for the main while loop
								% set at the beginning and increased at the end of every
								% pass of the loop is larger than one (that means that the
								% while loop is passed for more than one time til here)

  [ compensated_spectrum, matrix1, field_params1, field_params2 ] = adjust_matrix_size ( compensated_spectrum', field_params, time_params, matrix1', old_field_params, old_time_params );
  						% Adjust sizes of matrices: matrix from former pass of loop
  						% and matrix just read from the new fsc2 file

  compensated_spectrum = compensated_spectrum';
  matrix1 = matrix1';

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of compensated_spectrum:\t%4.2f %4.2f\n', size(compensated_spectrum));
    fprintf('\tSize of matrix1:\t\t%4.2f %4.2f\n', size(matrix1));
    fprintf('\tfield parameters1:\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield parameters2:\t\t%4.2f %4.2f %2.2f\n', field_params2);
  end;

  % frequency compensation

  fprintf('\n---------------------------------------------------------------------------\n');
  fprintf('\nCompensate frequency before accumulation of the spectra\n');
  
  drift_comp_data1 = compensated_spectrum;
  drift_comp_data2 = matrix1;
  								% set the matrices according to the necessary settings for the
  								% script file script_compensate_frequency.m
  
  [ drift_comp_data1, drift_comp_data2, field_params1, field_params2 ] = frequency_compensation(drift_comp_data1, drift_comp_data2, field_params1, field_params2, t, old_t);


  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of drift_comp_data1:\t%i %i\n', size(drift_comp_data1));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
  end;

  fprintf('\n---------------------------------------------------------------------------\n');
  fprintf('\nAccumulate spectra\n');
  
  % After plotting the overlay of both B_0 spectra
  % ask the user whether he really wants to proceed with accumulation...

  really_accumulate = menu( 'Do you really want to accumulate?', 'Yes, accumulate!', 'No, continue with old spectrum', 'No, continue with new spectrum' );

  if ( really_accumulate == 1 )
  						% if the user still wants to accumulate

	fprintf('\nYou decided to accumulate both spectra.\n')

    script_accumulate;
    						% call part of the script that does the accumulation

	average_frequency = ( average_frequency * num_accumulated_spectra + frequency ) / (num_accumulated_spectra + 1);

	num_accumulated_spectra = num_accumulated_spectra + 1;
						% increase value of counter
						
	filenames_accumulated = [ filenames_accumulated '\n\t' filename ];
    
  elseif ( really_accumulate == 2 )
  						% if the user wants to abort accumulation and
  						% wants to proceed with the old spectrum
  						
	fprintf('\nYou decided not to accumulate\n and to revert to the old spectrum.\n')
  	drift_comp_data = matrix1;
  						% set the old matrix to the actual matrix 
						
	filenames_not_accumulated = [ filenames_not_accumulated '\n\t' filename ];
  						
  else
  						% if the user wants to abort accumulation and
  						% wants to proceed with the new spectrum 
  						% just compensated
  						
	fprintf('\nYou decided not to accumulate\n and to continue with the just compensated spectrum.\n')
						
	filenames_not_accumulated = filenames_accumulated;
	filenames_accumulated = filename;

	average_frequency = frequency;
  
  end
     
  x = [ min([field_params1(1) field_params1(2)]) : abs(field_params1(3)) : max([field_params1(1) field_params1(2)]) ];
  
  % to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT
  x = x / 10;  

  plot(x,spectrum,'-',x,zeros(1,length(x)));
  
  
  
else 					% if first pass of main loop

  filenames_accumulated = filename;
  average_frequency = frequency;

end;						% end "if exit_main_loop" clause


exit_answer = menu ( 'What do you want to do now?', 'Read new file (and accumulate data)', 'Exit program');
						% make menu that lets the user choose which drift compensation
						% method he wants to use
						
if exit_answer == 1

  exit_main_loop = exit_main_loop + 1;
  
  if ( exist('acc_meas') == 0)
  						% in the case that there are no accumulated data

    matrix1 = compensated_spectrum;
  						% save compensated data to matrix1
  						
  else
  						% in the case that there are accumulated data
    matrix1 = acc_meas;
    						% save accumulated spectra to matrix1
  
  end;
  
  old_field_params = field_params;
  old_time_params = time_params;
  old_t = t;
  						% save parameters for comparison with the next spectrum
  						
  clear data drift* filename method* offset* pv* trigger_pos X Y;
						% clear old variables that are not used any more

  fprintf('\n###############################################################\n');
  fprintf('\n\tStarting round %i of accumulation routine...\n', exit_main_loop);
  fprintf('\n\tNumber of accumulated spectra: %i\n', num_accumulated_spectra);
  fprintf('\n###############################################################\n');

elseif exit_answer == 2

  num_compensated_spectra = exit_main_loop;
  exit_main_loop = 0;

end						% end of "if exit_answer" clause

end						% end of main while loop

% print some additional stuff to the figure

figure_title = '';		% default value for the figure title, in the case the user doesn't provide one...

fprintf('\nFIGURE TITLE\n');
figure_title = input ('\nPlease type in a figure title - normally the sample name and the temperature\n(the number of accumulations will be added automatically):\n  ', 's');

title_string = [figure_title ' (accumulated from '  num2str(num_accumulated_spectra) ' measurements)'];

fprintf('\nThe complete title will be as follows:\n\n\t%s\n', title_string);

title(title_string);
xlabel('B / mT')
ylabel('I')

if program == 'Octave'
  
else
  figure(gcf);			% set figure window to current figure window (gcf)
end;


% print some summarizing statistics and information

fprintf('\n---------------------------------------------------------------------------\n');
fprintf('\nSUMMARY OF THE PERFORMED ACTIONS:\n')

fprintf('\nTotal number of compensated spectra:\t%i', num_compensated_spectra);
fprintf('\nTotal number of accumulated spectra:\t%i\n', num_accumulated_spectra);

fprintf('\nThe following files were accumulated:\n\t');
fprintf(filenames_accumulated);

if ( (num_compensated_spectra-num_accumulated_spectra) > 0 )

  fprintf('\n\nThe following files were NOT accumulated:\n\t');
  fprintf(filenames_not_accumulated);

end;

fprintf('\n\nThe last displayed spectrum has been written to the file\n\t%s\n', outputfilename);
fprintf('\nThe field parameters are:\n\tfield boundaries:\t%4.2f - %4.2f\n\tField step width:\t%2.2f\n', field_params1);
fprintf('\nThe averaged frequency of the accumulated spectra is:\n\t%1.4f GHz\n', average_frequency);

fprintf('\nThe complete output of this program has been written to the file\n\t%s\n', logfilename);


total_time_used = toc;
fprintf ('\nThe total time used is %4.2f seconds\n', total_time_used);
						% print total time used;

fprintf('\n---------------------------------------------------------------------------\n');


% At the very end stop logging...

stop_logging;

% end of script