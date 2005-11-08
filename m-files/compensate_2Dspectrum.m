% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/26
% Derived from:		sample_script.m
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2
%
%	This file is intended to be used to compensate single 3D spectra 
%	recorded with the fsc2 software and save them as ASCII data to an output file.
%	The whole compensation process is being logged in a file that's name he user is
%	asked to provide at the very beginning of the processing of this script.
%
%	Although much effort has been made to give the user the necessary control over
%	the whole process of data manipulation there are several things that can be handled
%	in a better way.
%
%	The file may as well serve as an example for own scripts tailored to one's personal needs.


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
	DEBUGGING = 1;		% set DEBUGGING to ON
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



tic;						% set starting point for calculation of used time, just for fun...

% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate single 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\nThe whole compensation process is being logged in a file that''s name he user is\nasked to provide at the very beginning of the processing of this script.\n');

% First of all start logging

logfilename = start_logging;


% Then print some nice message
% saying what the script is all about

dateandtime = [datestr(now, 31), ' @ ', computer];

fprintf ( '\n%s\n', dateandtime )	% print current date and time and system

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate single 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');


% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

% Next ask for a file name to read and if file name is valid, read data

script_read_file;

% Plot raw data

field_boundaries = [ field_params(1) field_params(2) ];

[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

figure;

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


% Compensate drift along the B_0 axis

%fprintf('\nCompensate B_0 drift along the B_0 axis...\n')

%figure;							% Opens up a new plot window.

%drift2_comp_data = drift_compensation ( drift_comp_data, pv1, 20, 10);
								% Make weighted drift compensation along the B_0 axis
								% with linear (pv1) or quadratic (pv2) weights


%if program == 'Octave'			% if we're called by GNU Octave (as determined above)

%	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

%else								% otherwise we assume that we're called by MATLAB(R)

%	mesh ( X', Y', drift2_comp_data );
								% make simple 3D plot of the offset compensated data
%	title('data with drift compensated (weighted along B_0)');

%end


drift2_comp_data = drift_comp_data;


  % print 2D spectrum
  
  figure;						% opens new graphic window
  
  if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	title('accumulated and compensated data');
	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

  else							% otherwise we assume that we're called by MATLAB(R)

	mesh ( Y', X', drift2_comp_data );
								% make simple 3D plot of the offset compensated data
	title('accumulated and compensated data');

  end

  % print B_0 spectrum

  figure;						% opens new graphic window
  
  [spectrum,max_x] = B0_spectrum(drift2_comp_data,2);
 
  x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];

  % to convert from G -> mT
  x = x / 10;

  hold on;
  
  title(['B_0 spectrum of the file ' strrep(get_file_basename(filename),'_','\_')]);
  xlabel('B / mT');
  ylabel('I');
  
  plot(x,spectrum,x,zeros(1,length(x)));

  hold off;
  
% Save last dataset to file

outputfilename = [ get_file_path(filename) get_file_basename(filename) '-comp.' get_file_extension(filename) ];
								% the output filename consists of the path of the input file,
								% the basename of the input file with appended '-comp'
								% and the extension of the input file (normally '.dat')

fprintf('\nSaving ASCII data to the file\n\t%s\n', outputfilename);

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'drift2_comp_data');
%	save -ascii 'outputfilename' drift2_comp_data
								% save data to ascii file

else								% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'drift2_comp_data', '-ascii');
								% save data to ascii file in a MATLAB(R) compatible way
								% (silly MATLAB behaviour - to accept the Octave variant of
								% calling but neither saving nor complaining all about...)

    fig_output_filename = [ get_file_path(filename) get_file_basename(filename) '-B0-plot.eps' ];
	print('-depsc2', '-tiff', '-r300', fig_output_filename);

	fprintf('\nThe last plot has been saved to the file\n\t%s\n', fig_output_filename);
	
end

total_time_used = toc;
fprintf ('\nThe total time used is %i seconds\n\n', total_time_used);
						% print total time used;

% At the very end stop logging...

stop_logging;

new_logfilename = [ get_file_path(filename) get_file_basename(filename) '.log' ];

if ( strcmp(new_logfilename, logfilename) > 0 )
						% if the current logfile name and the suggested logfile name 
						% are not identical

  fprintf('\nFor clarity of the file names it is highly recommended to rename\nthe logfile to a name that matches the input file name,\n\n\t%s\n\n',filename);
  fprintf('\nThe suggested filename is\n\n\t%s\n\nPlease answer yes or no...\n',new_logfilename)

  rename_logfile = menu ('Do you want to rename the logfile?','Yes','No');

  if ( rename_logfile == 1)

    if program == 'Octave'	% if we're called by GNU Octave (as determined above)

      rename ( logfilename , new_logfilename );

    else					% otherwise we assume that we're called by MATLAB(R)
  
      movefile ( logfilename , new_logfilename );
  
    end;

    fprintf('\nLogfile renamed...\n\n');

  else

    fprintf('\nLogfile not renamed...\n\n');

  end
  
end

% end of script