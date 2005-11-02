% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/28
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, frequency compensation
%
%	This file is a sample main script to test the frequency_compensation routine.
%

fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );
fprintf('\nThis file is intended to be used to test the manual evaluation of the signal maximum of spectra\nrecorded with the fsc2 software.\nTherefore the user is first asked for a logfile file name...\n');


% First of all start logging

start_logging;


fprintf( '\nThis is the file $RCSfile$\n\t$Revision$ from $Date$\n' );

fprintf('\nThis file is intended to be used to test the manual evaluation of the signal maximum of spectra\nrecorded with the fsc2 software.\n');
fprintf('\nAlthough much effort has been made to give the user the necessary control over\nthe whole process of data manipulation there are several things that can be handled\nin a better way.\n');
fprintf('\nThe last versions of this file can be found at:\n\thttp://physik.fu-berlin.de/~biskup/\n');



% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

script_read_file;

filename_spectrum = filename;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );


% Plot B_0 spectrum and find signal maximum in t

figure;						% opens new graphic window

exit_find_max = 0;			% set while loop exit condition to default value;

t = trigger_pos;				% set time axis position to trigger position;

  
% set x vector for plotting

x = [ min([field_params(1) field_params(2)]) : field_params(3) : max([field_params(1) field_params(2)]) ];

x = x / 10;				% to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT


while ( exit_find_max == 0 )

  spectrum = B0_spectrum ( offset_comp_data, 2, t );
  
  clf;
  hold on;
  
  graph_title = [ 'B_0 spectrum for evaluating the maximum signal amplitude depending on t with t=', num2str(t) ];

  title(graph_title);
  xlabel('B / mT');
  ylabel('I');

  plot(x,spectrum',x,zeros(1,length(x)))
  
  hold off;
  
  freq_comp_option = menu ( 'What would you want to do?', '< t (1 step)', 't (1 step) >', '< t (10 step)', 't (10 step) >', 'Exit');
  
  if ( freq_comp_option == 1)
  
    t = t - 1;
  
  elseif ( freq_comp_option == 2)
  
    t = t + 1;
  
  elseif ( freq_comp_option == 3)
  
    t = t - 10;
  
  elseif ( freq_comp_option == 4)
  
    t = t + 10;
  
  elseif ( freq_comp_option == 5)
  
    exit_find_max = 1;
    					% set exit condition for while loop true
  
  end
  
end;							% end of while loop

real_t = time_params(3)/time_params(1) + time_params(2)/time_params(1);
							% calculate real time (in 1e-6 s) for the signal maximum
							% with time_params(1) = no_pointsm time_params(2) = trigger_pos
							% and time_params(3) = slice_length (in 1e-6 s)

fprintf('\nThe user evaluated maximum signal value lies at t=%i\nthat is %1.4f e-6 s after the trigger pulse.\n', t, real_t)


% Evaluate drift and possible fits

%script_drift;


  
% At the very end stop logging

stop_logging;

% end of script