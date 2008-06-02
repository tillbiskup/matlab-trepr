% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
%****f* interactive_programs.trEPR/compensate_accumulate_2Dspectra.m
%
% AUTHOR
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% MAINTAINER
%	Till Biskup <till.biskup@physik.fu-berlin.de>
% COPYRIGHT
%	(c) 2005 Till Biskup
%	This file is free software
% CREATION DATE
%	2005/10/26
% VERSION
%	$Revision$
% MODIFICATION DATE
%	$Date$
% DERIVED FROM
%	sample_accumulation_script.m
% KEYWORDS
%	transient EPR, fsc2, accumulate spectra
% 
% DESCRIPTION
%	This file is a sample main script that uses most of the implemented functions
%	for data analysis of trEPR data recorded with the program fsc2.
%	Therefore it depends on these functions that reside in the m-files in the 
%	same directory as this script.
%
%	The file serves as an example for own scripts.
%
%	The big difference tho the script 'compensate_2Dspectra' is that here the
%	main part that compensates for offset and drift resides in a loop and thus
%	the program allows to read several fsc2 files and accumulate the spectra.
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
%	START LOOP
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
%	8.	Save data
%
%	9.	[Frequency compensation]
%
%	10.	[Accumulation]
%
%	END LOOP
%
%	11.	Stop logging
%
%	Tasks 3 to 10 reside in one main loop that is processed until the user decides
%	to stop it.
%	Tasks 8 and 9 are only done beginning with the second pass of the main loop.
%
% SOURCE

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

  fprintf('\n%% DEBUGGING ON\n%%');

end;

if ( exist('PLOTTING3D') == 0 )	
						% in the case the debug variable is not set...

	global PLOTTING3D;
	PLOTTING3D = 0;		% set PLOTTING3D to OFF
						% if PLOTTING3D <> 0 then additional 3D PLOTS are generated

end;

if ( PLOTTING3D )		% in the case the plot3d variable is set...

  fprintf('\n%% 3D PLOTS ON\n%%');

end;

% Set number of B_0 slices that are averaged to display one B_0 spectrum
% Normally this is set to 5 and has to be an odd number

no_accumulated_B0_slices = 9;

% calculate the average_halfwidth (parameter for the function B0_spectrum)
% from the no_accumulated_B0_slices parameter set above.

B0_halfwidth = floor((no_accumulated_B0_slices-1)/2);

% END setting of global variables
% ######################################################################

% set starting point for calculation of used time, just for fun...
tic;

% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

stringGeneralDescriptionBeforeLogging = [...
	'\nThis is the program'...
	'\n   $Id$'...
	'\n'...
	'\nThis program is intended to be used to compensate and accumulate 2D spectra'...
	'\nrecorded with the fsc2 software and save them as ASCII data to an output file.'...
	'\n'...
	'\nThe whole compensation process is being logged in a file that''s name he user is'...
	'\nasked to provide at the very beginning of the processing of this program.'...
	'\n'...
];

fprintf(stringGeneralDescriptionBeforeLogging);

% For a better overview, create a subdirectory where everything created from this
% script is located at.

%-% subdirname = sprintf('2Dacc-%s',datestr(now,'yyyymmdd'));
%-% [mkdirstat,mkdirmess, mkdirmessid] = mkdir (subdirname);

% First of all start logging

logfilename = start_logging;

fprintf ( '\n%% NOTE: A summary of the performed actions will be displayed at the end.\n%%' )

stringGeneralDescription = [...
	'\n%% ---------------------------------------------------------------------------\n%%'...
	'\n%% GENERAL DESCRIPTION OF THE PROGRAM'...
	'\n%% =================================='...
	'\n%%'...
	'\n%% This is the program'...
	'\n%%   $Id$'...
	'\n%% that is part of the trEPR toolbox.'...
	'\n%%'...
	'\n%% This program is intended to be used to compensate and accumulate 2D spectra'...
	'\n%% recorded with the fsc2 software and save them as ASCII data to an output file.'...
	'\n%%'...
	'\n%% Although much effort has been made to give the user the necessary control'...
	'\n%% over the whole process of data manipulation there are several things that'...
	'\n%% can be handled in a better way.'...
	'\n%%'...
	'\n%% The latest version of this file along with some documentation can be found'...
	'\n%% on the internet at:'...
	'\n%%   http://physik.fu-berlin.de/~biskup/forschung/datenauswertung/trEPR-toolbox/'...
	'\n%%'...
	'\n%% NOTE: The revision of any routine and script called is logged in the logfile.'...
	'\n%%       Therefore it is possible to track back any errors or problems with'...
	'\n%%       one specific revision of one part of the program thanks to the'...
	'\n%%       revision control system.'...
	'\n%%'...
	'\n%% The following tasks are performed by the program and repeated for every'...
	'\n%% spectrum the user provides. (Tasks in brackets depend on whether the user'...
	'\n%% chooses to perform them):'...
	'\n%%'...
	'\n%%   1. [Cut spectrum]'...
	'\n%%   2. Compensate pretrigger offset'...
	'\n%%   3. Evaluate maximum signal amplitude according to t'...
	'\n%%   4. Evaluate drift'...
	'\n%%   5. Save data'...
	'\n%%   6. [Frequency compensation]'...
	'\n%%   7. [Accumulation]'...
	'\n%%'...
];

fprintf(stringGeneralDescription);

fprintf('\n%% ---------------------------------------------------------------------------\n%%');
fprintf('\n%% Find out whether we are called by MATLAB(R) or GNU Octave\n%%');

% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;
		% The variable "program" is in some mean a global variable as well.

fprintf('\n%% We''re called by %s\n%%',program);

% In case we are called by MATLAB(R) disable all warnings
if program == 'Matlab'

	warning('off','all');

end


exit_main_loop = 1;				% set exit condition for while loop

num_accumulated_spectra = 1;		% set number of accumulated spectra to 1 (default)

filenames_accumulated = '';
filenames_not_accumulated = '';

while exit_main_loop > 0			% main while loop
								% responsible for the possibility to accumulate
								% more than one spectrum after compensation
								% for pretrigger offset and drift


	fprintf('\n%% ---------------------------------------------------------------------------\n%%');
	fprintf('\n%% Read fsc2 data file...\n%%');

	% Next ask for a file name to read and if file name is valid, read data

	[ data,frequency,field_params,scope_params,time_params,filename,trigger_pos ] = trEPR_read_fsc2_file;

	% Plot raw data

	field_boundaries = [ field_params(1) field_params(2) ];

	if ( PLOTTING3D )		% in the case the plot3d variable is set...

	  fprintf('\n%% Plot raw data...\n%%')

	  [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

	  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	    gsplot ( data' );			% make simple 3D plot of the raw data

	  else								% otherwise we assume that we're called by MATLAB(R)

	    mesh ( data );				% make simple 3D plot of the raw data

	    title('Raw data');

	  end

	end;

	% Give user the possibility to cut off the spectrum at its start or end
	% by deleting a variable amount of time slices

	fprintf('\n%% ---------------------------------------------------------------------------\n%%')
	fprintf('\n%% Give the user the possibility to cut off the spectrum at its start or end...\n%%')

	[ dataRows, dataCols ] = size(data);

	if ( ( exist('old_t') == 0 ) || ( old_t > dataCols ) )

		[ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params, B0_halfwidth );

	else
	
		[ data, field_params ] = trEPR_cut_spectrum ( data, field_params, time_params, B0_halfwidth, old_t );

	end

	% Next compensate pretrigger offset

	fprintf('\n%% ---------------------------------------------------------------------------\n%%');
	fprintf('\n%% Compensate pretrigger offset\n%%' );

	data = pretrigger_offset ( data, trigger_pos );


	% Give user the possibility to manually evaluate the t value at which the signal
	% amplitude of the B_0 spectrum is maximal, BUT ONLY in case that hasn't been
	% performed before - otherwise the same parameters for 't' are used.

	if ( ( exist('old_t') == 0 ) || ( old_t > dataCols ) )

		fprintf('\n%% ---------------------------------------------------------------------------\n%%')
		fprintf('\n%% Give the user the possibility to manually evaluate the t value at which\n%% the signal amplitude of the B_0 spectrum is maximal\n%%')

		[ t, real_t ] = trEPR_find_maximum_amplitude ( data, field_params, time_params, B0_halfwidth );

	else
	
		t = old_t;
		real_t = old_real_t;

	end

	% Evaluate drift and possible fits

	fprintf('\n%% ---------------------------------------------------------------------------\n%%');
	fprintf('\n%% Evaluate drift and possible fits...\n%%');
	fprintf('\n%% Choose between the display modes...\n%%');

	drift_comp_data = trEPR_compensate_drift ( data, field_params, time_params, t, B0_halfwidth );

	% Save last dataset to file

	fprintf('\n%% ---------------------------------------------------------------------------\n%%');
	fprintf('\n%% Save compensated data to file\n%%');

	outputfilename = [ get_file_path(filename) get_file_basename(filename) '-comp2D.' get_file_extension(filename) ];
								% the output filename consists of the path of the input file,
								% the basename of the input file with appended '-comp2D'
								% and the extension of the input file (normally '.dat')

	fprintf('\n%% Saving ASCII data to the file\n%%\t%s\n%%', outputfilename)
								% Telling the user what's going to happen

	ascii_save_2Dspectrum ( outputfilename, drift_comp_data, field_params, time_params, frequency );

	if exit_main_loop > 1
		% if the exit condition for the main while loop
		% set at the beginning and increased at the end of every
		% pass of the loop is larger than one (that means that the
		% while loop is passed for more than one time til here)

		[ drift_comp_data, matrix1, field_params1, field_params2 ] = adjust_matrix_size ( drift_comp_data, field_params, time_params, matrix1, old_field_params, old_time_params );
  			% Adjust sizes of matrices: matrix from former pass of loop
  			% and matrix just read from the new fsc2 file

		% DEBUGGING OUTPUT
		if ( DEBUGGING )
			fprintf('\n%% DEBUGGING OUTPUT:\n%%');
			fprintf('\tSize of drift_comp_data:\t%4.2f %4.2f\n%%', size(drift_comp_data));
			fprintf('\tSize of matrix1:\t\t%4.2f %4.2f\n%%', size(matrix1));
			fprintf('\tfield parameters1:\t\t%4.2f %4.2f %2.2f\n%%', field_params1);
			fprintf('\tfield parameters2:\t\t%4.2f %4.2f %2.2f\n%%', field_params2);
		end;

		% frequency compensation

		fprintf('\n%% ---------------------------------------------------------------------------\n%%');
		fprintf('\n%% Compensate frequency before accumulation of the spectra\n%%');
								
		[ data1, data2, field_params1, field_params2 ] = trEPR_compensate_frequency ( drift_comp_data, matrix1, field_params1, field_params2, t, t, B0_halfwidth );

		field_params = field_params1;
		
		% DEBUGGING OUTPUT
		if ( DEBUGGING )
			fprintf('\n%% DEBUGGING OUTPUT:\n%%');
			fprintf('\tSize of drift_comp_data1:\t%i %i\n%%', size(drift_comp_data1));
			fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n%%', field_params1);
			fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n%%', field_params2);
		end;

		fprintf('\n%% ---------------------------------------------------------------------------\n%%');
		fprintf('\n%% Accumulate spectra\n%%');
  
		% After plotting the overlay of both B_0 spectra
		% ask the user whether he really wants to proceed with accumulation...

		really_accumulate = menu( 'Do you really want to accumulate?', 'Yes, accumulate!', 'No, continue with old spectrum', 'No, continue with new spectrum' );

		if ( really_accumulate == 1 )
  			% if the user still wants to accumulate

			fprintf('\n%% You decided to accumulate both spectra.\n%%')

			acc_meas = accumulate_measurements ( data2, data1 );
 
			% Save accumulated measurements

			user_provided_filename = input ( ' Please enter a filename for the ASCII file for saving the accumulated data\n% (if empty, the last input filename will be used with -acc2D appended\n% at the filename base):\n   ', 's' );

			if length( user_provided_filename ) > 0	
				% If the user provided a filename

				outputfilename = user_provided_filename;
  
			else	
				% In case the user didn't provide a filename

				outputfilename = [ get_file_path(filename) get_file_basename(filename) '-acc2D.' get_file_extension(filename) ];
					% the output filename consists of the path of the input file,
					% the basename of the input file with appended '-acc'
					% and the extension of the input file (normally '.dat')

			end

			fprintf('\n%% Saving ASCII data to the file\n%%\t%s\n%%', outputfilename)
				% Telling the user what's going to happen

			ascii_save_2Dspectrum ( outputfilename, acc_meas, field_params, time_params, frequency );

			% print B_0 spectrum of accumulated data

			if (isvector(acc_meas) == 0)

				[spectrum,max_x] = B0_spectrum(acc_meas,B0_halfwidth,t);
    
			else
  
				spectrum = acc_meas;
  
			end;


			average_frequency = ( average_frequency * num_accumulated_spectra + frequency ) / (num_accumulated_spectra + 1);

			num_accumulated_spectra = num_accumulated_spectra + 1;
				% increase value of counter
						
			filenames_accumulated = [ filenames_accumulated '\n%%   ' filename ];
	
			drift_comp_data = acc_meas;
    
		elseif ( really_accumulate == 2 )
  			% if the user wants to abort accumulation and
  			% wants to proceed with the old spectrum
  						
			fprintf('\n%% You decided not to accumulate\n%% and to revert to the old spectrum.\n%%')
			drift_comp_data = matrix1;
  				% set the old matrix to the actual matrix 
						
			filenames_not_accumulated = [ filenames_not_accumulated '\n%%   ' filename ];
  						
		else
  			% if the user wants to abort accumulation and
  			% wants to proceed with the new spectrum 
  			% just compensated
  						
			average_frequency = frequency;

			fprintf('\n%% You decided not to accumulate\n%% and to continue with the just compensated spectrum.\n%%')
						
			filenames_not_accumulated = filenames_accumulated;
			filenames_accumulated = filename;
  
		end
  
	else 					% if first pass of main loop

		filenames_accumulated = filename;
		average_frequency = frequency;

		if ( PLOTTING3D )
			% in the case the plot3d variable is set...

			% print 2D spectrum
  
			[X,Y] = meshgrid ( min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
				% set X and Y matrices for the mesh command
  
			figure;
				% opens new graphic window
  
			if program == 'Octave'
				% if we're called by GNU Octave (as determined above)

				title('accumulated and compensated data');
				gsplot ( drift_comp_data' );
					% make simple 3D plot of the offset compensated data

			else	
				% otherwise we assume that we're called by MATLAB(R)

				mesh ( X', Y', drift_comp_data );
					% make simple 3D plot of the offset compensated data
				title('accumulated and compensated data');

			end;

		end;					% if (PLOTTING3D)

	end;						% end "if exit_main_loop" clause


	% print B_0 spectrum of the last dataset
  
	[spectrum,max_x] = B0_spectrum(drift_comp_data,B0_halfwidth,t);
		% evaluate B_0 spectrum and its maximum

	x = [ min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]) ];
	% x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
		% set x axis values from field parameters
  
	% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT
	x = x / 10;  

	plot(x,spectrum,x,zeros(1,length(x)));
		% plot spectrum and line at y=0

	% as we are now at the end of one complete compensation cycle, ask the user what to
	% do next. The two options are to continue with a new file or to stop compensation here
	% and exit the program after some additional settings.

	exit_answer = menu ( 'What do you want to do now?', 'Read new file (and accumulate data)', 'Exit program');
		% make menu that lets the user choose how he wants to continue
						
	if exit_answer == 1

		exit_main_loop = exit_main_loop + 1;
  
		if ( exist('acc_meas') == 0)
  			% in the case that there are no accumulated data

			matrix1 = drift_comp_data;
  				% save compensated data to matrix1
  						
		else
			% in the case that there are accumulated data
			
			matrix1 = acc_meas;
				% save accumulated spectra to matrix1
  
		end;
  
		old_field_params = field_params;
		old_time_params = time_params;
		old_t = t;
		old_real_t = real_t;
  			% save parameters for comparison with the next spectrum
  						
		clear data drift* filename method* offset* pv* trigger_pos X Y;
			% clear old variables that are not used any more

		fprintf('\n%% ###############################################################\n%%');
		fprintf('\n%% \tStarting round %i of accumulation routine...\n%%', exit_main_loop);
		fprintf('\n%% \tNumber of accumulated spectra: %i\n%%', num_accumulated_spectra);
		fprintf('\n%% ###############################################################\n%%');

	elseif exit_answer == 2

		num_compensated_spectra = exit_main_loop;
		exit_main_loop = 0;

	end						% end of "if exit_answer" clause

end						% end of main while loop

% print some additional stuff to the figure
hold on;

figure_title = '';		% default value for the figure title, in the case the user doesn't provide one...

fprintf('\n%% FIGURE TITLE\n%%');
figure_title = input ('\n% Please type in a figure title - normally the sample name and the temperature\n% (the number of accumulations will be added automatically):\n  ', 's');

title_string = [figure_title ' (#acc: ' num2str(num_accumulated_spectra) ')'];

fprintf('\n%% The complete title will be as follows:\n%%\n%%\t%s\n%%\n%%', title_string);

title(title_string);
xlabel('B / mT')
ylabel('I')

hold off;

if program == 'Octave'
  
else
  figure(gcf);			% set figure window to current figure window (gcf)
end;


% Save last plot as an EPS file

user_provided_filename = input ( ' Please enter a file BASENAME for saving the last plot\n% (if empty, the last input filename will be used):\n   ', 's' );

if length( user_provided_filename ) > 0	
						% If the user provided a filename

  outputfilename = user_provided_filename;
  
else					% In case the user didn't provide a filename

  outputfilename = [ get_file_path(filename) get_file_basename(filename) ];
						% the output filename consists of the path of the input file,
						% the basename of the input file and the extension '.eps'

end

fprintf('\n%% Saving last plot to the file\n%%\t%s (with proper extensions added)\n%%', outputfilename)
						% Telling the user what's going to happen

save_figure ( outputfilename );
  

% print some summarizing statistics and information

stringSummaryHead = [...
	'\n%% ---------------------------------------------------------------------------\n%%'...
	'\n%% SUMMARY'...
	'\n%% ======='...
];

stringSummaryProgramHead = [...
	'\n%%'...
	'\n%% A. PROGRAM SPECIFIC VALUES'...
	'\n%% --------------------------'...
	'\n%%'...
	'\n%% Program version'...
	'\n%%   $Id$'...
	'\n%%'...
];

stringSummaryDataHead = [...
	'\n%%'...
	'\n%% B. DATA SPECIFIC VALUES'...
	'\n%% -----------------------'...
	'\n%%'...
];

fprintf( stringSummaryHead );
fprintf( stringSummaryProgramHead );

fprintf('\n%% Logfile\n%%   %s\n%%', logfilename);

total_time_used = toc;
fprintf ('\n%% Total time used\n%%   %4.2f seconds\n%%', total_time_used);

fprintf ('\n%% Date and time\n%%   %s\n%%', datestr(now, 31));

DisplayPlatform = platform;
fprintf ('\n%% Platform\n%%   %s\n%%', DisplayPlatform);

fprintf( stringSummaryDataHead );

fprintf('\n%% Display of B_0 spectra');
fprintf('\n%%   number of slices averaged:   %i', no_accumulated_B0_slices);
fprintf('\n%%   position of slices in time: %5.2f us\n%%', real_t);

fprintf('\n%% Number of involved spectra');
fprintf('\n%%   compensated spectra:  %i', num_compensated_spectra);
fprintf('\n%%   accumulated spectra:  %i\n%%', num_accumulated_spectra);

fprintf('\n%% Files accumulated:\n%%   ');
fprintf(filenames_accumulated);

if ( (num_compensated_spectra-num_accumulated_spectra) > 0 )

  fprintf('\n%%\n%% Files NOT accumulated:\n%%  ');
  fprintf(filenames_not_accumulated);

end;

if ( exist('field_params1') ~= 0)
	% That means we haven't accumulated but only compensated one spectrum

  field_params = field_params1;

end;

fprintf('\n%% \n%% The last displayed figure has been saved as (EPS) file\n%%   %s.eps\n%%', outputfilename);
fprintf('\n%% Field parameters\n%%   field boundaries:  %4.2f - %4.2f G\n%%   Field step width:  %2.2f G\n%%', field_params);
fprintf('\n%% Averaged frequency of the accumulated spectra:\n%%   %1.4f GHz\n%%', average_frequency);

fprintf('\n%% ---------------------------------------------------------------------------\n');


% At the very end stop logging...

stop_logging;

% end of script

%******