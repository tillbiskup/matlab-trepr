% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/11/07
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, maximal signal amplidude
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%

fprintf('\n---------------------------------------------------------------------------\n')
fprintf('\nGive user the possibility to manually evaluate the t value at which\nthe signal amplitude of the B_0 spectrum is maximal\n')

% Plot B_0 spectrum and find signal maximum in t

grfhandle = figure;			% opens new graphic window

exit_find_max = 0;			% set while loop exit condition to default value;

[ max_values, max_index ] = max( max( offset_comp_data ));
[ min_values, min_index ] = min( min( offset_comp_data ));

t = max_index;				% set time axis position to the t value of the maximum value of the script;

  
% set x vector for plotting

x = [ min([field_params(1) field_params(2)]) : abs(field_params(3)) : max([field_params(1) field_params(2)]) ];

x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT



  % DEBUGGING OUTPUT
  if ( DEBUGGING )
    fprintf('\nDEBUGGING OUTPUT:\n');
    fprintf('\tfield_params:\t%4.2f %4.2f %2.2f\n', field_params);
    fprintf('\tsize of x:\t\t%4.0f %4.0f\n', size(x));
    fprintf('\tsize of spectrum:\t\t%4.0f %4.0f\n', size(spectrum));
  end;


while ( exit_find_max == 0 )

  spectrum = B0_spectrum ( offset_comp_data, 2, t );
  
  figure(grfhandle);
  
  clf;
  hold on;
  
  graph_title = [ 'B_0 spectrum for evaluating the maximum signal amplitude depending on t with t=', num2str(t) ];

  title(graph_title);
  xlabel('B / mT');
  ylabel('I');

  axis([ (min([field_params(1) field_params(2)])/10) (max([field_params(1) field_params(2)])/10) min_values max_values]);

  plot(x,spectrum',x,zeros(1,length(x)))
  
  hold off;
  
  freq_comp_option = menu ( 'What would you want to do?', '< t (1 step)', 't (1 step) >', '< t (10 step)', 't (10 step) >', 'Type in t value manually', 'Show 2D Spectrum', 'Exit');
  
  if ( freq_comp_option == 1)
  
    t = t - 1;
  
  elseif ( freq_comp_option == 2)
  
    t = t + 1;
  
  elseif ( freq_comp_option == 3)
  
    t = t - 10;
  
  elseif ( freq_comp_option == 4)
  
    t = t + 10;
  
  elseif ( freq_comp_option == 5)

	t_manually = input ( '\nType in a t value manually: ', 's' );
	t = str2num (t_manually);
  
  elseif ( freq_comp_option == 6)
  
	fprintf('\nPlot 2D spectrum of offset-compensated data...\n')

	figure;

	[X,Y] = meshgrid ( min(field_boundaries) : abs(field_params(3)) : max(field_boundaries), 0 : time_params(3)/time_params(1) : time_params(3)-(time_params(3)/time_params(1)));
						% set X and Y matrices for the mesh command

	if program == 'Octave'			% if we're called by GNU Octave (as determined above)

	  gsplot ( offset_comp_data' );			% make simple 3D plot of the raw data

	else								% otherwise we assume that we're called by MATLAB(R)

	  mesh ( offset_comp_data );				% make simple 3D plot of the raw data

	title('2D plot of offset-compensated data');

  end
	
  elseif ( freq_comp_option == 7)
  
    exit_find_max = 1;
    					% set exit condition for while loop true
  
  end
  
end;							% end of while loop

real_t = time_params(3)/time_params(1) + time_params(2)/time_params(1);
							% calculate real time (in 1e-6 s) for the signal maximum
							% with time_params(1) = no_pointsm time_params(2) = trigger_pos
							% and time_params(3) = slice_length (in 1e-6 s)

fprintf('\nThe user evaluated maximum signal value lies at t=%i\nthat is %1.4f e-6 s after the trigger pulse.\n', t, real_t)


% end of script