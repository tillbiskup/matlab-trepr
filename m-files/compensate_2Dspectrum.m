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


tic;						% set starting point for calculation of used time, just for fun...

% Just to tell the user what's going on...
% This message is not logged, thus it will be repeated after the start of logging

fprintf( '\nThis is the file $RCSfile$, $Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to compensate single 3D spectra\nrecorded with the fsc2 software and save them as ASCII data to an output file.\nThe whole compensation process is being logged in a file that''s name he user is\nasked to provide at the very beginning of the processing of this script.\n');

% First of all start logging

start_logging;


% Then print some nice message
% saying what the script is all about

dateandtime = [datestr(now, 31), ' @ ', computer];

fprintf ( '\n%s\n', dateandtime )	% print current date and time and system

fprintf( '\nThis is the file $RCSfile$, $Revision$ from $Date$\n' );

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

fprintf('\nEvaluate drift and possible fits...\n')

drift_display = menu ( 'DRIFT COMPENSATION: Which display mode should be used?', 'Show drift and fit curve', 'Show B_0 spectrum at signal maximum' )

if ( drift_display == 1)

  script_drift;

else

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
  
  plot(x,spectrum,'-',x,zeros(1,length(x)));


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