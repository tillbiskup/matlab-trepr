% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/26
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, cut off, time slices
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%

% Give user the possibility to cut off the spectrum at its start or end
% by deleting a variable amount of time slices

fprintf('\nPossibility to cut off the spectrum at its start or end...\n')

% To be sure no signal is cut off
% first print a B_0 spectrum

[ spectrum, max_index ] = B0_spectrum ( data, 2 );

fprintf( '\nIndex of maximum value: %i\n', max_index );
 
x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];

figure; 				
 				
plot(x,spectrum','-',x,zeros(1,length(x)),'-');

cut_off = 0;				% set variable to default value that matches while condition

original_data = data;
original_field_params = field_params;

while (cut_off ~= 3)

  last_data = data;
  last_field_params = field_params;

  cut_off = menu ( 'Do you want to cut off time slices at beginning and/or end of the spectrum?', 'Yes, at the beginning', 'Yes, at the end', 'No', 'Undo last cut', 'Revert to original spectrum' );

  if ( cut_off == 1 )
						% if the user chose to cut off the beginning

    no_first_ts = input ( 'How many time slices do you want to cut of AT THE BEGINNING? ' );
    
    [ data, field_params ] = cut_off_time_slices ( data, no_first_ts, 0, field_params );

    
    % Plot raw data with cut time slices

    field_boundaries = [ field_params(1) field_params(2) ];

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

  elseif ( cut_off == 2 )
						% if the user chose to cut off the end

    no_last_ts = input ( 'How many time slices do you want to cut of AT THE END? ' );
    
    [ data, field_params ] = cut_off_time_slices ( data, 0, no_last_ts, field_params );
  
    % Plot raw data with cut time slices

    field_boundaries = [ field_params(1) field_params(2) ];

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

  elseif ( cut_off == 4 )
						% if the user chose to undo the last cut off
						
	data = last_data;
	field_params = last_field_params;

    field_boundaries = [ field_params(1) field_params(2) ];

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

  elseif ( cut_off == 5 )
						% if the user chose to revert to the original spectrum
						
	data = original_data;
	field_params = original_field_params;

    field_boundaries = [ field_params(1) field_params(2) ];

    [X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

  end					% if condition

  if ( ( field_params == original_field_params ) )
  
    fprintf( '\nNo cut off of the spectrum made.\n' );
  
  end

  if program == 'Octave'
  						% if we're called by GNU Octave (as determined above)

    gsplot ( data' );
	    					% make simple 3D plot of the raw data

  else					% otherwise we assume that we're called by MATLAB(R)

    mesh ( X', Y', data );
						% make simple 3D plot of the raw data

    title('Raw data');

  end
  
end						% end while (cut_off < 3) loop
