% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/18
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2
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

disp ( 'Sample script for testing the routines implemented' );
disp ( 'to analyse trEPR data recorded with the program fsc2.' );
disp ( 'WITH POSSIBILITY TO ACCUMULATE THE SPECTRA.' );


% First of all ask user for a log file filename

logfilename = input ( 'Please enter a filename for the log file (if empty, default will be used): ', 's' );

diary ('off')				% in case that the diary function is already started, stop it.

if length( logfilename ) > 0	
							% If the user provided a filename

  fprintf ( '\nFile %s will be used as logfile for the current session...\n\n', logfilename );
  
  diary ( logfilename );		% start logging via the 'diary' function
  
else							% In case the user didn't provide a filename

  logfilename = [(datestr (now,30)),'.dat']
  							% generate logfile filename from current date and time ('now')
  							% formatted as string with 'T' as separator: YYYYMMDDTHHMMSS
  							
  fprintf ( '\nFile %s will be used as logfile for the current session...\n\n', logfilename );
  
  diary ( logfilename );		% start logging via the 'diary' function
  
end


% Then print some nice message

dateandtime = [datestr(now, 31), ' @ ', computer];

disp ( dateandtime )	% print current date and time and system
 
disp ( ' ' );
disp ( 'Sample script for testing the routines implemented' );
disp ( 'to analyse trEPR data recorded with the program fsc2.' );
disp ( 'WITH POSSIBILITY TO ACCUMULATE THE SPECTRA.' );
disp ( ' ' );
disp ( 'Version:        $Revision$ from $Date$' );
disp ( 'Maintained by:  Till Biskup <till.biskup@physik.fu-berlin.de>' );
disp ( '	        http://www.physik.fu-berlin.de/~biskup/auswertung' );
disp ( ' ' );


% Find out whether we are called by MATLAB(R) or GNU Octave

disp ( 'Find out whether we are called by MATLAB(R) or GNU Octave...' );

[ program, prog_version ] = discriminate_matlab_octave;


exit_condition = 1;				% set exit condition for while loop

while exit_condition > 0			% main while loop
								% responsible for the possibility to accumulate
								% more than one spectrum after compensation
								% for pretrigger offset and drift

% Next ask for a file name to read and if file name is valid, read data

do

filename = input ( 'Please enter a filename of a fsc2 data file: ', 's' );

if length( filename ) > 0			% If the user provided a filename

  if program == 'Octave'			% if we're called by GNU Octave (as determined above)
  
  	filename = tilde_expand ( filename );
  								% expand filenames with tilde
  	
  end							% end if program == 'Octave'
  
  if exist(filename) = 0
  
    fprintf ( 'File not found!' );
    
  end
  
else								% In case the user didn't provide a filename

  fprintf ( 'You have not entered any file name!\n\n' );
								% just print a short message and exit
  filename = 'foo.bar';
  
end

until exist(filename);


fprintf ( '\nFile %s will be read...\n\n', filename );
  
[ data, trigger_pos ] = read_fsc2_data ( filename );
								% try to open the file and read the data


% Plot raw data

% fprintf('\nPlot raw data...\n')

% if program == 'Octave'			% if we're called by GNU Octave (as determined above)

%	gsplot ( data' );			% make simple 3D plot of the raw data

% else								% otherwise we assume that we're called by MATLAB(R)

%	mesh ( data );				% make simple 3D plot of the raw data

%	title('Raw data');

%end


% Next compensate pretrigger offset

offset_comp_data = pretrigger_offset ( data, trigger_pos );

% fprintf('\n...press any key to continue...\n')

% pause;

% Plot pretrigger offset compensated data

% fprintf('\nPlot pretrigger offset compensated data...\n')

% figure;						% Opens up a new plot window.

% if program == 'Octave'			% if we're called by GNU Octave (as determined above)

%	gsplot ( offset_comp_data' );
								% make simple 3D plot of the offset compensated data

%else								% otherwise we assume that we're called by MATLAB(R)

%	mesh ( offset_comp_data );
								% make simple 3D plot of the offset compensated data

%	title('data with pretrigger offset compensated');

%end


% fprintf('\n...press any key to continue...\n')

% pause;

% Evaluate drift and possible fits

fprintf('\nEvaluate drift and possible fits...\n')

figure;				% Opens up a new plot window.

[drift,p1,pv1,p2,pv2] = drift_evaluation (offset_comp_data,20);


[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
x = [1:1:drift_cols];		% create x-axis values 

title('Drift, linear and quadratic fit');
plot(x,drift,'-',x,pv1,'-',x,pv2,'-');
						% plot drift against x
						% values of linear fit against x (pv1 = polyval_1st_order)
						% values of quadratic fit against x (pv2 = polyval_2nd_order)

title('Drift, linear and quadratic fit');


method_drift_comp = menu ( 'Choose an option for drift compensation', 'linear', 'quadratic', 'none' );
						% make menu that lets the user choose which drift compensation
						% method he wants to use

% Compensate drift along the time axis

fprintf('\nCompensate B_0 drift along the t axis...\n')

% figure;						% Opens up a new plot window.

if ( method_drift_comp == 1 )
						% if the user chose linear fit

  fprintf('\nLinear drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv1);

elseif ( method_drift_comp == 2 )
						% if the user chose quadratic fit

  fprintf('\nQuadratic drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv2);

else						% if user chose to do no fit at all

  fprintf('\nNo drift compensation method chosen...\n');
  
  drift_comp_data = offset_comp_data;
  						% set drift_comp_data to offset_comp_data without further computation

end

%if program == 'Octave'			% if we're called by GNU Octave (as determined above)

%	gsplot ( drift_comp_data' );
								% make simple 3D plot of the offset compensated data

%else								% otherwise we assume that we're called by MATLAB(R)

%	mesh ( drift_comp_data );
								% make simple 3D plot of the offset compensated data
%	title('data with (quadratic) drift compensated');

%end


%fprintf('\n...press any key to continue...\n')

%pause;

% Compensate drift along the B_0 axis

fprintf('\nCompensate B_0 drift along the B_0 axis...\n')

figure;						% Opens up a new plot window.

drift2_comp_data = drift_compensation ( drift_comp_data, pv1, 20, 10);
								% Make weighted drift compensation along the B_0 axis
								% with linear (pv1) or quadratic (pv2) weights


if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('data with drift compensated (weighted along B_0)');
	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( drift2_comp_data );
								% make simple 3D plot of the offset compensated data
	title('data with drift compensated (weighted along B_0)');

end


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

if exit_condition > 1				% if the exit condition for the main while loop
								% set at the beginning and increased at the end of every
								% pass of the loop is larger than one (that means that the
								% while loop is passed for more than one time til here)

fprintf('\nAccumulate measurements...\n')
								% Telling the user what's going to happen

  acc_meas = accumulate_measurements ( drift2_comp_data, matrix1 );
  								% accumulate the measurements compensated until here
  
  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('accumulated and compensated data');
	gsplot ( acc_meas' );
								% make simple 3D plot of the offset compensated data

  else							% otherwise we assume that we're called by MATLAB(R)

	mesh ( acc_meas );
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
						% with appended extension ".out"
	
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

end						% end of "if program" clause

  
end;						% end "if exit_condition" clause


exit_answer = menu ( 'What do you want to do now?', 'Read new file (and accumulate data)', 'Exit program');
						% make menu that lets the user choose which drift compensation
						% method he wants to use
						
if exit_answer == 1

  exit_condition = exit_condition + 1
  
  matrix1 = drift2_comp_data;
  						% save compensated data to matrix
  						
  clear data drift* filename method* offset* p1 p2 trigger_pos x;

elseif exit_answer == 2

  exit_condition = 0;

end						% end of "if exit_answer" clause

end						% end of main while loop

total_time_used = toc;
fprintf ('\nThe total time used is %i seconds\n\n', total_time_used);
						% print total time used;

% At the very end stop logging...

diary('off')			% logging via the diary function stopped

% end of script