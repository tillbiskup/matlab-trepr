% Copyright (C) 2005 Till Biskup
% 
% This file ist free software.
% 
% Author:			Till Biskup <till.biskup@physik.fu-berlin.de>
% Maintainer:		Till Biskup <till.biskup@physik.fu-berlin.de>
% Created:			2005/10/26
% Version:			$Revision$
% Last Modification:	$Date$
% Keywords:			transient EPR, fsc2, drift
%
% IMPORTANT NOTE
% This script is part of other scripts dealing with data analysis and compensation
% of spectra recorded with the fsc2 software and requires some variables to be set
% in the current workspace.
%
% Later on there will be a list of all these variables or perhaps the whole script
% will be converted into a function...
%
% The big advantage of this script over the script named script_drift.m is that here
% not the drift at the end of the time axis is plottet but instead the B_0 spectrum
% at the maximum signal amplitude as it is used later on for further analysis. Thus
% the drift compensation method can be fitted to the "real" spectrum.
% 


% Evaluate drift and possible fits

fprintf('\nEvaluate drift and possible fits...\n')

[drift,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (offset_comp_data,20);


[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
x = [1:1:drift_cols];		% create x-axis values 

figure;					% Opens up a new plot window.

    
[ spectrum, max_ind ] = B0_spectrum ( offset_comp_data, 2 );
x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
plot(x,spectrum,'-',x,zeros(1,length(x)));

% plot(x,drift,'-');
						% plot drift against x
						% values of linear fit against x (pv1 = polyval_1st_order)
						% values of quadratic fit against x (pv2 = polyval_2nd_order)

title('Drift and polynomic fit');

exit_condition = 0;

while ( exit_condition == 0 )

  method_drift_comp = menu ( 'Choose an option for drift compensation', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Continue with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use


  if ( method_drift_comp == 1 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv1);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));
    
    chosen_method = '1st order';

  elseif ( method_drift_comp == 2 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv2);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '2nd order';

  elseif ( method_drift_comp == 3 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv3);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '3rd order';

  elseif ( method_drift_comp == 4 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv4);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '4th order';

  elseif ( method_drift_comp == 5 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv5);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '5th order';

  elseif ( method_drift_comp == 6 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv6);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '6th order';

  elseif ( method_drift_comp == 7 )

    drift_comp_data = drift_compensation_along_t(offset_comp_data, trigger_pos, 100, 10, pv7);
    
    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = '7th order';

  elseif ( method_drift_comp == 8 )

    drift_comp_data = offset_comp_data;

    [ spectrum, max_ind ] = B0_spectrum ( drift_comp_data, 2 );
    x = [ min(field_boundaries) : abs(field_params(3)) : max(field_boundaries) ];
    plot(x,spectrum,'-',x,zeros(1,length(x)));

    chosen_method = 'none';

  elseif ( method_drift_comp == 9 )

    exit_condition = 1;

  end
  
end

fprintf( '\nEventually chosen drift compensation method: %s\n', chosen_method );
