% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/09/28
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

tic;						% set starting point for calculation of used time, just for fun...

% Just to tell the user what's going on...

disp ( 'Sample script for testing the routines implemented' );
disp ( 'to analyse trEPR data recorded with the program fsc2.' );


% First of all start logging

start_logging;


% Then print some nice message

dateandtime = [datestr(now, 31), ' @ ', computer];

disp ( dateandtime )	% print current date and time and system
 
disp ( ' ' );
disp ( 'Sample script for testing the routines implemented' );
disp ( 'to analyse trEPR data recorded with the program fsc2.' );
disp ( ' ' );
disp ( 'Version:        $Revision$ from $Date$' );
disp ( 'Maintained by:  Till Biskup <till.biskup@physik.fu-berlin.de>' );
disp ( '	        http://www.physik.fu-berlin.de/~biskup/auswertung' );
disp ( ' ' );


% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

filename = ' ';					% set filename to empty value
								% the space is necessary not to confuse GNU Octave

while (exist(filename) == 0)		% while there is no valid filename specified
								% This would be better done with a do...until loop
								% but silly MATLAB(R) doesn't support this...

  filename = input ( 'Please enter a filename of a fsc2 data file: ', 's' );

  if (length( filename ) > 0)		% If the user provided a filename

    if program == 'Octave'		% if we're called by GNU Octave (as determined above)
  
  	  filename = tilde_expand ( filename );
  								% expand filenames with tilde
  	
    end							% end if program == 'Octave'
  
    if (exist(filename) == 0)
  
      fprintf ( 'File not found!' );
    
    end
  
  else							% In case the user didn't provide a filename

    fprintf ( 'You have not entered any file name!\n\n' );
								% just print a short message and exit
    filename = 'foo.bar';
  
  end

end		% end of while exist(filename) loop


fprintf ( '\nFile %s will be read...\n\n', filename );
  
[ data, frequency, field_params, scope_params, time_params ] = read_fsc2_data ( filename );
  								% open the file and read the data
trigger_pos = time_params(2);	% get trigger_pos out of time_params


% Plot raw data

field_boundaries = [ field_params(1) field_params(2) ];

[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

fprintf('\nPlot raw data...\n')

if program == 'Octave'	% if we're called by GNU Octave (as determined above)

	gsplot ( data' );	% make simple 3D plot of the raw data

else						% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', data );
						% make simple 3D plot of the raw data

	title('Raw data');

end

cut_off = 0;				% set variable to default value that matches while condition

while (cut_off < 3)

  cut_off = menu ( 'Do you want to cut off time slices at beginning and/or end of the spectrum?', 'Yes, at the beginning', 'Yes, at the end', 'No' );

  if ( cut_off == 1 )
						% if the user chose to cut off the beginning

    no_first_ts = input ( 'How many time slices do you want to cut of AT THE BEGINNING? ' );
    
    [ data, field_params ] = cut_off_time_slices ( data, no_first_ts, 0, field_params );

    
    % Plot raw data with cut time slices

    field_boundaries = [ field_params(1) field_params(2) ]

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

	size(X)
	size(Y)
	size(data)

    fprintf('\nPlot raw data...\n')

    if program == 'Octave'
    						% if we're called by GNU Octave (as determined above)

	    gsplot ( data' );
	    					% make simple 3D plot of the raw data

    else					% otherwise we assume that we're called by MATLAB(R)

	    mesh ( X', Y', data );
						% make simple 3D plot of the raw data

	    title('Raw data');

    end

  elseif ( cut_off == 2 )
						% if the user chose to cut off the end

    no_last_ts = input ( 'How many time slices do you want to cut of AT THE END? ' );
    
    [ data, field_params ] = cut_off_time_slices ( data, 0, no_last_ts, field_params );
  
    % Plot raw data with cut time slices

    field_boundaries = [ field_params(1) field_params(2) ]

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

    fprintf('\nPlot raw data...\n')

    if program == 'Octave'
    						% if we're called by GNU Octave (as determined above)

	    gsplot ( data' );
	    					% make simple 3D plot of the raw data

    else					% otherwise we assume that we're called by MATLAB(R)

	    mesh ( X', Y', data );
						% make simple 3D plot of the raw data

	    title('Raw data');

    end

  end					% if condition
  
end						% end while (cut_off < 3) loop

% Next compensate pretrigger offset

offset_comp_data = pretrigger_offset ( data, trigger_pos );

fprintf('\n...press any key to continue...\n')

pause;

% Plot pretrigger offset compensated data

fprintf('\nPlot pretrigger offset compensated data...\n')

figure(2);						% Opens up a new plot window.

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( offset_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', offset_comp_data );
								% make simple 3D plot of the offset compensated data

	title('data with pretrigger offset compensated');

end


fprintf('\n...press any key to continue...\n')

pause;

% Evaluate drift and possible fits

fprintf('\nEvaluate drift and possible fits...\n')

figure(3);				% Opens up a new plot window.

[drift,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (offset_comp_data,20);


[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
x = [1:1:drift_cols];		% create x-axis values 

plot(x,drift,'-',x,pv1,'-',x,pv2,'-',x,pv3,'-',x,pv4,'-',x,pv5,'-',x,pv6,'-',x,pv7,'-');
						% plot drift against x
						% values of linear fit against x (pv1 = polyval_1st_order)
						% values of quadratic fit against x (pv2 = polyval_2nd_order)

title('Drift, linear, quadratic and cubic fit');


method_drift_comp = menu ( 'Choose an option for drift compensation', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none' );
						% make menu that lets the user choose which drift compensation
						% method he wants to use

% Compensate drift along the time axis

fprintf('\nCompensate B_0 drift along the t axis...\n')

figure(4);						% Opens up a new plot window.

if ( method_drift_comp == 1 )
						% if the user chose linear fit

  fprintf('\nLinear drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv1);

elseif ( method_drift_comp == 2 )
						% if the user chose quadratic fit

  fprintf('\nQuadratic drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv2);

elseif ( method_drift_comp == 3 )
						% if the user chose cubic fit

  fprintf('\nCubic drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv3);

elseif ( method_drift_comp == 4 )
						% if the user chose 4th order fit

  fprintf('\n4th order drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv4);

elseif ( method_drift_comp == 5 )
						% if the user chose 5th order fit

  fprintf('\n5th order drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv5);

elseif ( method_drift_comp == 6 )
						% if the user chose 6th order fit

  fprintf('\n6th order drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv6);

elseif ( method_drift_comp == 7 )
						% if the user chose 7th order fit

  fprintf('\n7th order drift compensation method chosen...\n');

  drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv7);

else						% if user chose to do no fit at all

  fprintf('\nNo drift compensation method chosen...\n');
  
  drift_comp_data = offset_comp_data;
  						% set drift_comp_data to offset_comp_data without further computation

end

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( drift_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', drift_comp_data );
								% make simple 3D plot of the offset compensated data
	title('data with (quadratic) drift compensated');

end


fprintf('\n...press any key to continue...\n')

pause;

% Compensate drift along the B_0 axis

fprintf('\nCompensate B_0 drift along the B_0 axis...\n')

figure(5);						% Opens up a new plot window.

drift2_comp_data = drift_compensation ( drift_comp_data, pv1, 20, 10);
								% Make weighted drift compensation along the B_0 axis
								% with linear (pv1) or quadratic (pv2) weights


if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( X', Y', drift2_comp_data );
								% make simple 3D plot of the offset compensated data
	title('data with drift compensated (weighted along B_0)');

end


% Save last dataset to file

outputfilename = [ filename, '.out'];

fprintf('\nSaving ASCII data to the file %s...\n', outputfilename)

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'drift2_comp_data');
%	save -ascii 'outputfilename' drift2_comp_data
								% save data to ascii file

else								% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'drift2_comp_data', '-ascii');
								% save data to ascii file in a MATLAB(R) compatible way
								% (silly MATLAB behaviour - to accept the Octave variant of
								% calling but neither saving nor complaining all about...)

end

total_time_used = toc;
fprintf ('\nThe total time used is %i seconds\n\n', total_time_used);
						% print total time used;

% At the very end stop logging...

stop_logging;

% end of script