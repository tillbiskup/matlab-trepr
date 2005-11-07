% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, accumulate 2D spectra
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%


  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nSTART OF $RCSfile$\n');
  end;

% Accumulate 2D spectra

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of drift_comp_data1:\t%i %i\n', size(drift_comp_data1));
    fprintf('\tSize of drift_comp_data2:\t%i %i\n', size(drift_comp_data2));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
  end;

  fprintf('\nAccumulate measurements...\n')
								% Telling the user what's going to happen

  acc_meas = accumulate_measurements ( drift_comp_data1, drift_comp_data2 );
  								% accumulate the measurements compensated until here

  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tSize of drift_comp_data1:\t%i %i\n', size(drift_comp_data1));
    fprintf('\tSize of drift_comp_data2:\t%i %i\n', size(drift_comp_data2));
    fprintf('\tSize of acc_meas:\t\t%i %i\n', size(acc_meas));
    fprintf('\tfield_params1:\t\t\t%4.2f %4.2f %2.2f\n', field_params1);
    fprintf('\tfield_params2:\t\t\t%4.2f %4.2f %2.2f\n', field_params2);
    fprintf('\tfield_params:\t\t\t%4.2f %4.2f %2.2f\n', field_params);
  end;

  if ( PLOTTING3D )
  
	figure;						% opens new graphic window
  
	[X,Y] = meshgrid ( min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command
  
	if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	  title('accumulated and compensated data');
	  gsplot ( acc_meas' );
								% make simple 3D plot of the offset compensated data

	else							% otherwise we assume that we're called by MATLAB(R)

	  mesh ( X', Y', acc_meas );
								% make simple 3D plot of the offset compensated data
	  title('accumulated and compensated data');

	end
	
  end
  
  % Save accumulated measurements

  user_provided_filename = input ( 'Please enter a filename for the ASCII file for saving the accumulated data\n(if empty, the last input filename will be used with -acc appended\n at the filename base):\n   ', 's' );

  if length( user_provided_filename ) > 0	
						% If the user provided a filename

	outputfilename = user_provided_filename;
	
	fprintf ( '\nFile %s will be used to store the ASCII data of the accumulated data...\n\n', outputfilename );
  
  else					% In case the user didn't provide a filename


	outputfilename = [ get_file_path(filename) get_file_basename(filename) '-acc.' get_file_extension(filename) ];
						% the output filename consists of the path of the input file,
						% the basename of the input file with appended '-acc'
						% and the extension of the input file (normally '.dat')

	fprintf ( '\nThe ASCII data of the accumulated data will be stored in the file\n\t%s\n', outputfilename );

  end

  fprintf('\nSaving ASCII data to the file\n\t%s\n', outputfilename)
						% Telling the user what's going to happen

  if program == 'Octave'	% if we're called by GNU Octave (as determined above)

	save ('-ascii', outputfilename, 'acc_meas');
						% save data to ascii file

  else					% otherwise we assume that we're called by MATLAB(R)

	save (outputfilename, 'acc_meas', '-ascii');
						% save data to ascii file in a MATLAB(R) compatible way
						% (silly MATLAB behaviour - to accept the Octave variant of
						% calling but neither saving nor complaining all about...)

  end					% end of "if program" clause
  

  % print B_0 spectrum of accumulated data

  figure;

  [spectrum,max_x] = B0_spectrum(acc_meas,2);
 
  x = [ min([field_params1(1) field_params1(2)]) : abs(field_params1(3)) : max([field_params1(1) field_params1(2)]) ];
  
  plot(x,spectrum,'-',x,zeros(1,length(x)));

  
  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nEND OF $RCSfile$\n');
  end;
  