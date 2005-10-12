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



% First of all print some nice message

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

filename = input ( 'Please enter a filename of a fsc2 data file: ', 's' );

if length( filename ) > 0			% If the user provided a filename

  fprintf ( '\nFile %s will be read...\n\n', filename );
  
  [ data, trigger_pos ] = read_fsc2_data ( filename );
  								% try to open the file and read the data
  
else								% In case the user didn't provide a filename

  error ( 'You have not entered any file name!' );
								% just print a short message and exit
  
end


% Plot raw data

fprintf('\nPlot raw data...\n')

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( data' );			% make simple 3D plot of the raw data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( data );				% make simple 3D plot of the raw data

	title('Raw data');

end


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

	mesh ( offset_comp_data );
								% make simple 3D plot of the offset compensated data

	title('data with pretrigger offset compensated');

end


fprintf('\n...press any key to continue...\n')

pause;

% Evaluate drift and possible fits

fprintf('\nEvaluate drift and possible fits...\n')

figure(3);				% Opens up a new plot window.

[drift,p1,pv1,p2,pv2] = drift_evaluation (offset_comp_data,20);


[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
x = [1:1:drift_cols];		% create x-axis values 

plot(x,drift,'-',x,pv1,'-',x,pv2,'-');
						% plot drift against x
						% values of linear fit against x (pv1 = polyval_1st_order)
						% values of quadratic fit against x (pv2 = polyval_2nd_order)

title('Drift, linear and quadratic fit');


method_drift_comp = menu ( 'Choose an option for drift compensation', 'linear', 'quadratic', 'none' );
						% make menu that lets the user choose which drift compensation
						% method he wants to use

% Compensate drift along the time axis

fprintf('\nCompensate drift...\n')

figure(4);						% Opens up a new plot window.

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

if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( drift_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( drift_comp_data );
								% make simple 3D plot of the offset compensated data
	title('data with (quadratic) drift compensated');

end


fprintf('\n...press any key to continue...\n')

pause;

% Compensate drift along the B_0 axis

fprintf('\nCompensate drift once again...\n')

figure(5);						% Opens up a new plot window.

drift2_comp_data = drift_compensation ( drift_comp_data, pv1, 20, 10);
								% Make weighted drift compensation along the B_0 axis
								% with linear (pv1) or quadratic (pv2) weights


if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	gsplot ( drift2_comp_data' );
								% make simple 3D plot of the offset compensated data

else								% otherwise we assume that we're called by MATLAB(R)

	mesh ( drift2_comp_data );
								% make simple 3D plot of the offset compensated data
	title('data with drift compensated (weighted along B_0)');

end


% end of script