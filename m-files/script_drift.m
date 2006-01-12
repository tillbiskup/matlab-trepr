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
%
% INPUT
%
% OUTPUT
%
% TASKS
%	- Convert script to a function
%


% Evaluate drift and possible fits

[drift,pv1,pv2,pv3,pv4,pv5,pv6,pv7] = drift_evaluation (offset_comp_data,20);


[ drift_rows, drift_cols ] = size ( drift );
						% evaluate the size of the drift vector
						% to create the x-axis values
								
x = [1:1:drift_cols];		% create x-axis values 

figure;					% Opens up a new plot window.

plot(x,drift);
						% plot drift against x

title('Drift and polynomic fit');

exit_condition = 0;

while ( exit_condition == 0 )

  method_drift_comp = menu ( 'Choose an option for drift compensation', '1st oder', '2nd order', '3rd order', '4th order', '5th order', '6th order', '7th order', 'none', 'Compensate with chosen method...');
						% make menu that lets the user choose which drift compensation
						% method he wants to use


  if ( method_drift_comp == 1 )

    plot(x,drift,x,pv1);

  elseif ( method_drift_comp == 2 )

    plot(x,drift,x,pv2);

  elseif ( method_drift_comp == 3 )

    plot(x,drift,'-',x,pv3,'-');

  elseif ( method_drift_comp == 4 )

    plot(x,drift,'-',x,pv4,'-');

  elseif ( method_drift_comp == 5 )

    plot(x,drift,'-',x,pv5,'-');

  elseif ( method_drift_comp == 6 )

    plot(x,drift,'-',x,pv6,'-');

  elseif ( method_drift_comp == 7 )

    plot(x,drift,'-',x,pv7,'-');

  elseif ( method_drift_comp == 8 )

    exit_condition = 1;

  elseif ( method_drift_comp == 9 )

    exit_condition = 1;

    if exist ( 'old_method' )
    						% if user chose this option instead od "none"
    						% but hasn't chosen any other option the variable
    						% 'old_method' does not exist...

      method_drift_comp = old_method;
      
    end;
    
  end
  
  old_method = method_drift_comp;
  						% to save the previously chosen drift compensation
  						% method
  
end

% Compensate drift along the time axis

fprintf('\nCompensate B_0 drift along the t axis...\n')

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
