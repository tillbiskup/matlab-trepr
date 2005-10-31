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

disp ( 'Sample script for testing the frequency compensation routine' );


% First of all start logging

start_logging;



% Find out whether we are called by MATLAB(R) or GNU Octave

[ program, prog_version ] = discriminate_matlab_octave;


% Next ask for a file name to read and if file name is valid, read data

script_read_file;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );

% Evaluate drift and possible fits

script_drift;

  
drift_comp_data1 = drift_comp_data;
frequency1 = frequency;
field_params1 = field_params;
scope_params1 = scope_params;
time_params1 = time_params;
trigger_pos1 = time_params1(2);	% get trigger_pos out of time_params



% Then ask for a second file name to read and if file name is valid, read data

script_read_file;


% Next compensate pretrigger offset

fprintf( '\nCompensate pretrigger offset\n' )

offset_comp_data = pretrigger_offset ( data, trigger_pos );

% Evaluate drift and possible fits

script_drift;

  
drift_comp_data2 = drift_comp_data;
frequency2 = frequency;
field_params2 = field_params;
scope_params2 = scope_params;
time_params2 = time_params;
trigger_pos2 = time_params2(2);	% get trigger_pos out of time_params



% Next, plot overlay of both B_0 spectra


fprintf('\nPrinting B_0 spectra for frequency compensation...\n')
								% Telling the user what's going to happen
								
[ spectrum1, max_index1 ] = B0_spectrum ( drift_comp_data1, 2 );
  
[ spectrum2, max_index2 ] = B0_spectrum ( drift_comp_data2, 2 );
  
figure;						% opens new graphic window

exit_freq_comp = 0;			% set while loop exit condition to default value;

offset1 = 0;					% set offset1 to default value;
offset2 = 0;					% set offset2 to default value;

while ( exit_freq_comp == 0 )
  
  x1 = [ 1+offset1 : 1 : size( drift_comp_data1( :, max_index1 ))+offset1 ];
  x2 = [ 1+offset2 : 1 : size( drift_comp_data1( :, max_index1 ))+offset2 ];

  % to convert from G -> mT	1 G = 10e-4 T = 10e-1 mT

  x1 = x1 / 10000;
  x2 = x2 / 10000;
  
  clf;
  hold on;

  title('1D Plot of both B_0 spectra for frequency alignment')
  xlabel('B / mT');
  ylabel('I');

  plot(x1,spectrum1','-',x2,spectrum2','-',x1,zeros(1,length(x1)),'-')

  legend( {'Spectrum 1','Spectrum 2'} )
  
  hold off;
  
  freq_comp_option = menu ( 'What would you want to do?', '< spectrum1', 'spectrum1 >', '< spectrum2', 'spectrum2 >', 'Exit');
  
  if ( freq_comp_option == 1)
  
    offset1 = offset1 - 1;
  
  elseif ( freq_comp_option == 2)
  
    offset1 = offset1 + 1;
  
  elseif ( freq_comp_option == 3)
  
    offset2 = offset2 - 1;
  
  elseif ( freq_comp_option == 4)
  
    offset2 = offset2 + 1;
  
  elseif ( freq_comp_option == 5)
  
    exit_freq_comp = 1;
    					% set exit condition for while loop true
  
  end
  
end;							% end of while loop

% fprintf('\nOffset1: %i; Offset2: %i\n',offset1, offset2);

if ( ( offset1 ~= 0 ) | ( offset2 ~= 0 ) )

  startcut1 = 0;
  endcut1 = 0;
  startcut2 = 0;
  endcut2 = 0;

  if ( offset1 > 0 )
  
    endcut1 = offset1;

    fprintf('\nSpectrum 1 shifted %i Gauss to the right\n', endcut1);
    
  end

  if ( offset1 < 0 )
  
    startcut1 = abs(offset1);

    fprintf('\nSpectrum 1 shifted %i Gauss to the left\n', startcut1);
    
  end

  if ( offset2 > 0 )
  
    endcut2 = offset2;

    fprintf('\nSpectrum 2 shifted %i Gauss to the right\n', endcut2);
    
  end

  if ( offset2 < 0 )
  
    startcut2 = abs(offset2);

    fprintf('\nSpectrum 2 shifted %i Gauss to the left\n', startcut2);
    
  end

  [ r1, c1 ] = size ( drift_comp_data1 );
  [ r2, c2 ] = size ( drift_comp_data2 );

  
  drift_comp_data1 = drift_comp_data1( 1+abs(startcut1-endcut2) : r1-abs(endcut1-startcut2) , : );

  if ( field_params1(1) < field_params1(2))
  						% if spectrum recorded from low to high field

    field_params1 = [ field_params1(1)+(abs(startcut1-endcut2)*field_params1(3)), field_params1(2)-(abs(endcut1-startcut2)*field_params1(3)), field_params1(3) ];

  else
  						% if spectrum recorded from high to low field

    field_params1 = [ field_params1(1)-(abs(endcut1-startcut2)*field_params1(3)), field_params1(2)+(abs(startcut1-endcut2)*field_params1(3)), field_params1(3) ];

  end;

  drift_comp_data2 = drift_comp_data2( 1+abs(startcut2-endcut1) : r2-abs(endcut2-startcut1) , :);

  if ( field_params2(1) < field_params2(2))
  						% if spectrum recorded from low to high field

    field_params2 = [ field_params2(1)+(abs(endcut2-startcut1)*field_params2(3)), field_params2(2)-(abs(startcut2-endcut1)*field_params2(3)), field_params2(3) ];
    

  else
  						% if spectrum recorded from high to low field

    field_params2 = [ field_params2(1)-(abs(startcut2-endcut1)*field_params2(3)), field_params2(2)+(abs(endcut2-startcut1)*field_params2(3)), field_params2(3) ];

  end;


  fprintf('\nSpectrum 1 and spectrum 2 are cut to fit to each other.\n');
  fprintf('\tNew dimensions of both spectra: %i rows, %i cols.\n', size(drift_comp_data1));

  fprintf('\n\tNew field parameter for both spectra:.\n');
  fprintf('\t\tfield borders:\t\t%4.2f G - %4.2f G\n\t\tfield step width:\t%2.2f G\n', field_params1);

end;					% end if offset1 or offset 2 ~= 0


							
[ spectrum1, max_index1 ] = B0_spectrum ( drift_comp_data1, 2 );
  
[ spectrum2, max_index2 ] = B0_spectrum ( drift_comp_data2, 2 );

figure;						% opens new graphic window

x1 = [ min([field_params1(1) field_params1(2)]) : 0.5 : max([field_params1(1) field_params1(2)]) ];
x2 = [ min([field_params2(1) field_params2(2)]) : 0.5 : max([field_params2(1) field_params2(2)]) ];

% to convert from G -> mT

x1 = x1 / 10000;
x2 = x2 / 10000;

hold on;
  
title('1D Plot of the frequency aligned B_0 spectra')
xlabel('B / mT');
ylabel('I');

plot(x1,spectrum1','-',x2,spectrum2','-',x1,zeros(1,length(x1)),'-')

legend( {'Spectrum 1','Spectrum 2'} )
  
hold off;
  
% At the very end stop logging

stop_logging;

% end of script